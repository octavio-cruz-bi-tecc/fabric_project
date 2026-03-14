# Estrategia de Migración QAD → SAP en Arquitectura Medallion (Microsoft Fabric)

## Resumen ejecutivo

Este documento amplía la estrategia para incorporar datos de **SAP S/4 HANA Cloud Private Edition** en la arquitectura medallion existente (Bronze → Silver → Gold) que actualmente consume **QAD MFG**, de modo que los datamarts y vistas Gold sirvan datos de ambos ERPs de forma unificada y transparente para el usuario final.

**Conclusiones principales de la investigación:**

- **QAD MFG** expone datos mediante tablas operativas/financieras (ej. `cm_mstr`, `ad_mstr`, `ac_mstr`) con nomenclatura propia y estructura relativamente directa por entidad.
- **SAP S/4 HANA** utiliza un modelo basado en **CDS views** (~2.800 extractores), con tablas subyacentes muy normalizadas (KNA1, MARA, VBAK/VBAP, etc.); la extracción recomendada es vía CDS con anotación de extracción, no sobre tablas transaccionales crudas.
- La **arquitectura medallion en Microsoft Fabric** recomienda **una capa Silver unificada** que consolide múltiples fuentes Bronze (limpieza, estándares, dimensiones conformadas), y Gold consumiendo solo de Silver.
- Se proponen **tres estrategias** (incluyendo una híbrida) con criterios de decisión, recomendación y plan de implementación.

---

## 1. Situación actual (contexto ampliado)

### 1.1 Arquitectura Bronze existente

| Lakehouse | Contenido | Dominios / empresas |
|-----------|-----------|----------------------|
| **lh_bronze_qad1** | Copia espejo de tablas MFG QAD (servidor 1) | SCO, SEL |
| **lh_bronze_qad2** | Copia espejo de tablas MFG QAD (servidor 2) | PS, STU, SUS, HOS, IZD, IMA |
| **lh_bronze_sap** | Tablas materializadas desde CDS views (esquema SAPHANADB) | Un solo tenant SAP |

- Ambos servidores QAD comparten la **misma configuración y estructura de tablas** a nivel de BD (MFG es multidominio).
- **Tablas custom (prefijo XX):** Pueden tener **estructura distinta** entre lh_bronze_qad1 y lh_bronze_qad2. **Enfoque adoptado:** en el ETL Bronze → Silver se crea una sola tabla genérica por entidad XX en Silver, con **campos nullable** para compensar las columnas que existen en un origen pero no en el otro; así se mantiene una tabla única que contempla los campos de ambas fuentes XX.

### 1.2 Convenciones QAD en Bronze

- **Clave técnica:** `PROGRESS_RECID` en todas las tablas.
- **Dominio/empresa:** Campo con sufijo `_DOMAIN` (ej. `PO_DOMAIN`, `AD_DOMAIN`).
- **Fechas de cambio:** No todas las tablas las tienen; se usa UPDT_LOG (ver 1.4).

### 1.3 Capa Silver actual (lh_silver_erp)

- **“Estructura genérica consolidada”:** En **nombres** se usó nomenclatura genérica en snake_case e inglés, alineada al estilo SAP (renombrado de campos y tablas). En **estructura, diseño y normalización** la Silver quedó **muy parecida y apegada al estilo QAD**: es decir, no se rediseñó hacia un modelo típico SAP (altamente normalizado); se depuraron campos no usados, se renombraron y se consolidaron dominios, pero la forma de las tablas (granularidad, nivel de normalización) sigue siendo heredada de QAD. El **contrato** para integrar SAP es por tanto: mismo nombre de tablas/columnas y tipos que hoy tiene Silver, que es de “estilo QAD” en estructura.
- **company_code:** Sustituye al dominio QAD; todas las empresas consolidadas en la misma tabla por entidad.
- **source_system:** Ya presente en `sd.sales_order`, `sd.invoices`; debe extenderse a **todas** las tablas que reciban QAD + SAP.
- Esquemas: md, sd, mm, pp, fi, co, ecp, qm, dbo, etc.

### 1.4 Incremental en QAD (tablas sin timestamp en origen)

- Tabla **UPDT_LOG** en Oracle (TABLE_NAME, RECORD_ID, COMPANY_CODE, OPERATION_TYPE I/U/D, UPDATED_AT, UPDATED_BY).
- **Triggers** por tabla (ej. `TRG_AUDIT_AD_MSTR` sobre AD_MSTR) escriben en UPDT_LOG.
- UPDT_LOG se ingesta a Bronze; el ETL incremental usa esta tabla para saber qué registros refrescar.

### 1.5 Tablas de control (lh_control_erp)

| Tabla | Uso |
|-------|-----|
| **source_to_bronze_control** | QAD → Bronze (target_layer, watermark, load_type, etc.). |
| **source_to_bronze_control_sap** | SAP → Bronze; evita concurrencia. Incluye source_object, object_type, target_lakehouse. |
| **bronze_to_silver_control** | ETL Bronze QAD → Silver. |
| **bronze_to_silver_control_sap** | ETL Bronze SAP → Silver; source/target workspace/lakehouse, type_load. |
| **bronze_to_silver_sql_control** | Flujos Silver basados en SQL/vistas. |
| **silver_to_gold_control** | Silver → Gold (datamarts, surrogate_key, business_keys). |

- **load_type / type_load** definen Full vs Incremental por tarea; **watermark_column**, **last_watermark_value**, **updated_at_column**, **last_updated_at_value** soportan incremental.

### 1.6 Conectividad SAP

- Data Gateway on-premise con SAP HANA Connector y SAP HANA Database Client.
- Fabric: conectores **SAP Table Application Server** (CDS por SQL view name) y **SAP HANA Database** (schema SAPHANADB).
- Extracción piloto en lh_bronze_sap (IMATERIAL, I_CUSTOMER_CDS, ISDSALESORDER, IMATDOCITEM, etc.).

### 1.8 Cronograma de go-live SAP y tipos de empresa

- **Empresas con procesos de manufactura (más robustas):** Solo **3** operan la mayoría de módulos y procesos de manufactura: **SEL, SCO, STU**. Son las que concentran datamarts y vistas de reportes en Fabric.
- **Empresas puramente financieras:** El resto son empresas financieras; se liberan en **tres bloques** junto con las manufactureras. **Orden de go-live:** (1) **1.er bloque de financieras:** Febrero 2026 (ya en operación); (2) **SEL:** Abril 2026; (3) **STU + 2.º bloque de financieras:** Mayo 2026; (4) **SCO + último bloque de financieras:** Junio 2026.
- **Ventana de transición:** Aproximadamente **4 a 6 meses**. En la práctica, el foco de integración SAP para reportes y datamarts está en las 3 manufactureras (SEL, SCO, STU). **Situación actual (marzo 2026):** SEL sale en 1 mes (abril 2026).
- Implicación para la capa conformada y Gold: cada registro debe tener `company_code` y `source_system`; para reportes “actuales” por empresa puede usarse una tabla de control de fechas de go-live por `company_code` (ver sección 4.5).

### 1.9 Desafíos

- Mapeo SAP → estructura genérica Silver; transparencia en reportes.
- **Incremental SAP:** No todas las CDS tienen campo de última modificación (ver sección 6).
- Tablas XX: ya resueltas con tabla genérica en Silver y columnas nullable (ver 1.1).


---

## 2. Análisis en profundidad: QAD MFG vs SAP S/4 HANA

### 2.1 QAD MFG – Modelo de datos

- **Tipo:** Tablas operativas y financieras con nombres típicos (`_mstr`, `_det`).
- **Maestros:** Por ejemplo `cm_mstr` (clientes), `ad_mstr` (direcciones), `ac_mstr` (cuentas). Direcciones por dominio (bill-to, ship-to, etc.).
- **Transaccionales:** Múltiples tablas por área (ventas, envíos, contabilidad, activos). Documentación QAD: Database Definitions, Entity Diagrams.
- **Extracción:** Directa desde base de datos (replicación, ETL sobre tablas).

**Implicación:** Tu Silver actual ya “aplana” y estandariza estas tablas en una estructura genérica; ese contrato (nombres de columnas, tipos, granularidad y forma de tablas estilo QAD; ver 1.3) es la referencia para integrar SAP.

---

### 2.2 SAP S/4 HANA – Modelo de datos y extracción

- **Evolución vs R/3:** S/4 HANA simplificó el modelo (menos tablas de estado, índices redundantes), pero sigue siendo más normalizado que QAD.
- **Entidades clave y tablas/vistas típicas:**
  - **Clientes:** KNA1 (y vistas CDS tipo I_CUSTOMER).
  - **Materiales:** MARA y vistas CDS (ej. I_MATERIAL, vistas de inventario).
  - **Ventas:** VBAK (cabecera), VBAP (posiciones); vistas CDS **I_SALESORDER** (solo categoría ‘C’) o **I_SALESDOCUMENT** (todas las categorías). Para reporting unificado suele ser mejor I_SALESDOCUMENT o vistas custom sobre ella.
- **Método recomendado de extracción:** CDS views con **ODP (Operational Data Provisioning)**:
  - Anotaciones: `@Analytics.dataExtraction.enabled`, categoría (transaccional/atributos/textos).
  - Full load y delta (S/4 HANA 2018+).
  - Custom CDS Views (app “Custom CDS Views”) para escenarios de extracción cuando las vistas estándar no cubren el caso.

**Implicación:** En Bronze SAP no deberías replicar “tablas transaccionales crudas” sino, preferiblemente, **vistas CDS de negocio** (o custom CDS que las extiendan). Así Bronze SAP ya llega con un nivel de “una entidad por vista” y facilita el mapeo a tu Silver genérico.

---

### 2.3 Comparación resumida

| Aspecto           | QAD MFG                    | SAP S/4 HANA                          |
|------------------|----------------------------|----------------------------------------|
| Estructura       | Tablas por entidad         | Muy normalizado; una entidad = varias tablas/vistas |
| Extracción       | Tablas directas            | CDS views (ODP) sobre tablas           |
| Cliente          | cm_mstr + ad_mstr          | KNA1 + direcciones / I_CUSTOMER       |
| Material         | Tablas de ítem/maestro     | MARA + vistas / I_MATERIAL            |
| Órdenes venta    | Tablas propias             | VBAK/VBAP → I_SALESORDER / I_SALESDOCUMENT |
| Nomenclatura     | Propia QAD                 | Alemán/numérico (VBAK, KNA1, etc.)    |

**Conclusión:** Los modelos son distintos pero **convergen a nivel de negocio** (cliente, producto, orden de venta, factura, etc.). Es viable mapear SAP a la **misma estructura genérica de Silver** que ya tienes para QAD, con una columna `source_system` y reglas de mapeo explícitas.

---

## 3. Estrategias evaluadas

### 3.1 Estrategia 1: Silver unificado (una sola Silver para QAD + SAP)

**Arquitectura:**

- **Bronze:** Tres lakehouses: `lh_bronze_qad1` (SCO, SEL), `lh_bronze_qad2` (PS, STU, SUS, HOS, IZD, IMA), `lh_bronze_sap` (CDS views en SAPHANADB). Control: source_to_bronze_control (QAD) y source_to_bronze_control_sap (SAP).
- **Silver:** Un solo lakehouse `lh_silver_erp` con estructura genérica. Pipelines/notebooks por fuente que:
  - Leen de Bronze (lh_bronze_qad1, lh_bronze_qad2 o lh_bronze_sap).
  - Mapean a los mismos nombres y tipos de la estructura genérica.
  - Rellenan `source_system` ('QAD' | 'SAP').
  - Campos solo existentes en SAP: nullable o valor por defecto.
- **Gold:** Sin cambios estructurales; lee solo de `lh_silver_erp`. Origen de datos transparente.

**Ventajas:**

- Alineado con la guía de Fabric: una Silver unificada para múltiples fuentes.
- Gold simple y estable; reportes unificados sin UNIONs por fuente en Gold.
- Un solo lugar para reglas de limpieza, calidad y dimensiones conformadas.
- Máxima transparencia para el usuario final.

**Desventajas y mitigaciones:**

- Complejidad concentrada en Silver: muchos mapeos SAP→genérico.
  - **Mitigación:** Notebooks/pipelines parametrizados por entidad y por fuente; matriz de mapeo campo a campo; pruebas unitarias por entidad.
- Riesgo de desestabilizar el Silver actual.
  - **Mitigación:** No modificar los pipelines QAD existentes; añadir **nuevos** pipelines/notebooks que solo lean Bronze SAP y escriban en las **mismas** tablas Silver (misma estructura, con `source_system`). Fase piloto con una entidad (ej. clientes o productos) y validación antes de escalar.
- Performance: más datos y más transformaciones en Silver.
  - **Mitigación:** Particionado por `source_system` y fechas; Z-ordering donde aplique; revisar capacidad de Fabric.

**Cuándo elegirla:** Cuando quieres un único modelo de datos para negocio y estás dispuesto a invertir en mapeos y pruebas en Silver. Recomendada si el período de transición es largo (varios meses o más) y ambos ERPs convivirán de forma permanente en reportes.

---

### 3.2 Estrategia 2: Silver dual + Gold consolidado

**Arquitectura:**

- **Bronze:** Igual que en Estrategia 1 (lh_bronze_qad1, lh_bronze_qad2, lh_bronze_sap).
- **Silver:** Dos lakehouses:
  - `lh_silver_qad`: el actual (lh_silver_erp solo alimentado por QAD), sin cambios.
  - `lh_silver_sap`: nuevo; estructura idéntica al contrato genérico de Silver (snake_case, company_code), mapeada desde SAP; control vía bronze_to_silver_control_sap.
- **Gold:** ETL que lee de **ambos** Silvers y hace UNION/JOIN por entidad. Gold debe “conocer” las dos fuentes y aplicar reglas de consolidación (claves, SCD, etc.) en esta capa.

**Ventajas:**

- Aislamiento: el Silver QAD no se toca; menor riesgo operativo.
- Equipos pueden trabajar en paralelo (QAD vs SAP).
- Flexibilidad para que `lh_silver_sap` tenga temporalmente más campos nativos de SAP.

**Desventajas:**

- Complejidad y duplicación de lógica en Gold (UNIONs, mapeos, conformación de dimensiones).
- Gold deja de ser “agnóstico a la fuente”; cada vista/datamart debe considerar QAD y SAP.
- Dos estándares de Silver (dos esquemas) a mantener a largo plazo.

**Cuándo elegirla:** Si el período de transición es corto (< 6 meses), QAD pasará a solo histórico y no quieres tocar el Silver actual. También si los modelos son tan distintos que unificar en una sola Silver se considera inviable en el corto plazo.

---

### 3.3 Estrategia 3 (recomendada): Capa de conformación (Silver dual + capa conformada)

**Idea:** Mantener el Silver QAD intacto y crear un Silver SAP específico; añadir una **capa de conformación** que solo hace el merge y la conformación de dimensiones, y que Gold sigue consumiendo como “única” Silver desde el punto de vista lógico.

**Arquitectura:**

- **Bronze:** `lh_bronze_qad`, `lh_bronze_sap` (igual que en 1 y 2).
- **Silver por fuente:**
  - `lh_silver_qad`: sin cambios; mismo lh_silver_erp actual alimentado solo por lh_bronze_qad1 y lh_bronze_qad2 (control: bronze_to_silver_control).
  - `lh_silver_sap`: nuevo lakehouse; pipelines que transforman **solo** desde lh_bronze_sap hacia una estructura **idéntica** en nombres y tipos a la de Silver (mismo contrato), con `source_system = 'SAP'` y company_code desde MANDT o equivalente. Control: bronze_to_silver_control_sap.
- **Capa conformada (opción A – vistas):** Un lakehouse `lh_silver_erp` que **solo** contiene vistas (o tablas materializadas ligeras) que hacen UNION ALL de las tablas homólogas de `lh_silver_qad` y `lh_silver_sap`. Sin lógica de negocio adicional; solo unificación.
- **Capa conformada (opción B – tablas):** En lugar de vistas, un pipeline que lee de ambos Silvers, aplica deduplicación/SCD solo donde haga falta (ej. dimensión cliente con claves de ambos sistemas) y escribe en `lh_silver_erp` (tablas). Gold lee solo de `lh_silver_erp`.

**Gold:** Sin cambios; sigue leyendo de `lh_silver_erp` como hoy (o como en Estrategia 1). Sigue siendo transparente a la fuente.

**Ventajas:**

- No se modifican los pipelines Silver QAD existentes; riesgo bajo.
- La complejidad de SAP se contiene en `lh_silver_sap` (mapeo CDS → genérico).
- Un solo punto de consumo para Gold (`lh_silver_erp`), transparencia para el usuario.
- Si más adelante quieres migrar a “una sola Silver” (Estrategia 1), puedes ir moviendo la lógica de `lh_silver_sap` hacia un único Silver y eliminar la capa conformada.

**Desventajas:**

- Una capa más (conformada) que mantener; en la opción con vistas el coste es bajo.
- Dos Silvers técnicos (qad y sap) hasta que decidas colapsar a uno.

**Cuándo elegirla:** Cuando quieres transparencia en Gold y un único modelo de datos para reportes, pero quieres **minimizar el riesgo** sobre el Silver actual. Es la opción más equilibrada para un período de transición largo con ambos ERPs en producción.

---

## 4. Recomendación final: con qué estrategia quedarte

Con el contexto actual (dos Bronze QAD, Silver ya consolidado con estructura de estilo QAD y nombres genéricos tipo SAP, control, migración en curso a SAP, necesidad de transparencia en Gold, y **go-live por tipo de empresa**: 3 manufactureras robustas —SEL, SCO, STU—, resto financieras; transición de **4 a 6 meses**; ver 1.8 y 4.5), la recomendación **se mantiene: Estrategia 3 (Silver dual + capa conformada)**. A continuación el razonamiento según buenas prácticas y uso habitual en proyectos de migración de ERP.

### 4.1 Qué se usa en la práctica

- **Un solo Silver unificado (Estrategia 1)** es el patrón “de libro” en medallion y el que recomienda Fabric cuando diseñas desde cero: una Silver que recibe todas las fuentes, un solo lugar para reglas y Gold que solo lee de ahí. Es el más habitual en entornos nuevos o cuando puedes asumir que los pipelines nuevos (SAP) no impactan los existentes (QAD).
- **Silver por fuente + capa conformada (Estrategia 3)** es muy común en **migraciones y transiciones**: el Silver actual no se toca, se construye un Silver paralelo para la nueva fuente (SAP) con el mismo contrato y una capa fina (vistas o ETL ligero) que solo une. Gold sigue leyendo de un único punto. Se usa cuando el Silver existente es crítico y se quiere **cero riesgo de regresión** en reportes QAD.
- **Silver dual sin capa conformada (Estrategia 2)** suele elegirse cuando el periodo de transición es corto y QAD pasará pronto a solo histórico, y se acepta que Gold tenga que conocer ambas fuentes y hacer UNIONs/JOINs.

### 4.2 Por qué encaja la Estrategia 3 en tu caso

| Criterio | Cómo aplica en tu contexto | Estrategia 3 |
|----------|----------------------------|--------------|
| **Riesgo sobre el Silver actual** | Tienes muchos flujos QAD → Silver ya en producción y tablas de control; un error en un pipeline nuevo no debe afectar reportes QAD. | No se modifica ningún pipeline ni tabla Silver existente; todo lo de SAP vive en un lakehouse y pipelines nuevos. |
| **Transparencia en Gold** | Los usuarios no deben elegir “QAD” o “SAP”; los reportes deben mostrar datos unificados. | Gold sigue leyendo de un solo lugar (capa conformada); la unión QAD+SAP se resuelve en esa capa, no en Gold. |
| **Mantenibilidad y escalabilidad** | Ya usas tablas de control (incl. `bronze_to_silver_control_sap`); quieres algo ordenado y repetible. | Un equipo puede trabajar en lh_silver_sap y otro mantener QAD; la conformación es un punto único y simple (vistas o un ETL de solo merge). |
| **Periodo de transición** | Unas 4–6 meses; 3 manufactureras (SEL, SCO, STU) concentran datamarts/reportes; financieras en 3 bloques (1.er bloque Feb 2026 ya en SAP; 2.º y 3.er con STU y SCO en May/Jun 2026). | La Estrategia 3 encaja: dos Silvers técnicos, un contrato común, una capa que solo consolida; el foco de integración está en las manufactureras. |
| **Buenas prácticas** | Patrón “conformed dimension” / “staging then merge”: primero normalizas por fuente, luego unes. | lh_silver_qad y lh_silver_sap son el “staging” por fuente; la capa conformada es el “merge”; Gold consume el resultado. |

En resumen: **Estrategia 3** minimiza riesgo, mantiene un solo punto de consumo para Gold, se alinea con lo que se hace en migraciones ERP y es reversible (más adelante puedes pasar a Estrategia 1 moviendo la lógica de lh_silver_sap al Silver unificado y eliminando la capa conformada).

### 4.3 Cuándo considerar la Estrategia 1 en su lugar

- Si **priorizas tener menos capas** (un solo Silver físico) y **aceptas un riesgo controlado**: pipelines y notebooks **nuevos** solo para SAP que escriben en el mismo `lh_silver_erp`, sin tocar los flujos QAD. Requiere disciplina (no modificar pipelines QAD, probar bien por entidad) y un piloto (por ejemplo una entidad maestra) antes de escalar.
- Si tu organización prefiere el patrón “una Silver para todo” y tiene experiencia en mantener varios orígenes en el mismo lakehouse, la Estrategia 1 es válida; la Estrategia 3 sigue siendo la opción más segura para una migración en curso.

### 4.4 Resumen de la recomendación

- **Recomendación:** **Estrategia 3 (Silver dual + capa conformada)**.
  - Mantener el Silver actual (QAD) intacto; construir **lh_silver_sap** con la **misma estructura genérica** (contrato único: company_code, snake_case, mismos nombres de tabla y columnas que las tablas Silver actuales que vayan a recibir SAP).
  - Añadir una **capa de conformación** (mismo lakehouse lógico que hoy consume Gold, p. ej. `lh_silver_erp`): vistas que hagan UNION ALL de las tablas homólogas de lh_silver_qad y lh_silver_sap, o un ETL ligero que escriba tablas conformadas; Gold sigue leyendo solo de esa capa.
  - Usar **source_to_bronze_control_sap** y **bronze_to_silver_control_sap** para gobernar todos los flujos SAP (Full/Incremental según sección 6).

- **Alternativa:** **Estrategia 1** si prefieres una sola Silver física y asumes el riesgo controlado de añadir únicamente pipelines nuevos para SAP sobre el mismo Silver, sin tocar QAD.

- **Estrategia 2** solo si el periodo de transición es corto, QAD será pronto solo histórico y aceptas que Gold conozca ambas fuentes y haga la unión.

### 4.5 Go-live por empresa: cronograma y efecto en la recomendación

**Contexto real:**  
- **3 empresas manufactureras/robustas (SEL, SCO, STU):** operan la mayoría de módulos y procesos de manufactura; son las que concentran datamarts y vistas de reportes en Fabric.  
- **Resto: empresas puramente financieras**, en tres bloques. **Orden de go-live:** (1) 1.er bloque financieras Feb 2026; (2) SEL Abr 2026; (3) STU + 2.º bloque financieras May 2026; (4) SCO + último bloque financieras Jun 2026.  
- **Transición:** Aproximadamente **4 a 6 meses**; el peso de la integración SAP para reportes está en las 3 manufactureras. **Situación actual (marzo 2026):** SEL en 1 mes.

**¿Cambia la recomendación?** **No.** La Estrategia 3 sigue siendo la recomendada:

| Aspecto | Por qué aplica con este cronograma |
|---------|-------------------------------------|
| **Duración (4–6 meses)** | Sigue siendo una transición con ambos ERPs en paralelo; la Estrategia 3 evita tocar el Silver QAD durante ese periodo. |
| **Corte por empresa** | Orden go-live: 1.er bloque financieras (Feb 2026), SEL (Abr 2026), STU + 2.º bloque financieras (May 2026), SCO + último bloque financieras (Jun 2026). La capa conformada hace UNION con `company_code` y `source_system`; los reportes filtran por empresa y/o por sistema según necesidad. |
| **Riesgo** | No tocar el Silver QAD protege los reportes de las empresas que aún dependen de QAD; las financieras ya en SAP tuvieron poco impacto en Fabric. |
| **Foco** | Los datamarts y vistas críticos están en las 3 manufactureras; la integración SAP debe priorizar que esas empresas (SEL, SCO, STU) queden bien servidas desde la capa conformada. |

**Implementación en la capa conformada:**  
- Vistas **UNION ALL** de las tablas homólogas (QAD + SAP); cada fila con `company_code` y `source_system`. Para reportes “actuales” por empresa, usar una tabla de control **go-live por empresa** (ej. `company_code`, `sap_go_live_date`): para fechas &gt;= go-live se considera SAP, para fechas anteriores QAD (histórico).  
- La decisión “esta empresa ya está en SAP” se concentra en un único lugar (tabla de fechas de go-live o filtro por `source_system` + `company_code`).

---

## 5. Uso de la estructura Silver actual

**Conclusión:** Sí puedes reutilizar la estructura Silver actual como contrato para SAP.

- La Silver actual es **genérica en nombres** (snake_case, inglés, alineados a estilo SAP) pero **de estructura, diseño y normalización muy apegada a QAD** (ver 1.3). Ese contrato —mismas tablas, columnas y tipos— es al que debes mapear SAP: desde un modelo típicamente más normalizado (CDS/tablas SAP) hacia tablas con forma “estilo QAD” (misma granularidad y nivel de normalización que hoy tiene Silver).
- Para SAP:
  - En Bronze: ingestar **CDS views** (I_CUSTOMER, I_MATERIAL, I_SALESDOCUMENT o custom) en lugar de tablas transaccionales crudas.
  - En Silver (o en `lh_silver_sap` en Estrategia 3): transformaciones que mapeen campo a campo a esa estructura (nombres genéricos + forma QAD), con `source_system`, y campos solo-SAP como nullable o con valor por defecto. Habrá que “aplanar” o combinar datos de varias CDS/tablas SAP cuando una entidad de negocio en SAP esté repartida en varias tablas normalizadas.
- No es necesario crear “otra” Silver con otro modelo; lo que sí puede existir es un **Silver técnico por fuente** (Estrategia 3) que respeta el mismo contrato (nombres + estructura tipo QAD) y luego se consolida en la capa conformada.

---

## 6. Estrategias de actualización incremental para SAP (Bronze y Silver)

No todas las CDS views de SAP S/4 HANA exponen un campo de "última modificación" ni soportan delta nativo. A continuación se resumen las opciones para decidir **Full** vs **Incremental** por objeto y cómo registrarlo en las tablas de control (`source_to_bronze_control_sap`, `bronze_to_silver_control_sap`).

### 6.1 Opciones soportadas por SAP ODP / CDS

| Método | Descripción | Requisito en la CDS |
|--------|-------------|----------------------|
| **Full** | Carga completa cada ejecución. | Ninguno; siempre disponible. |
| **Delta por timestamp/fecha** | Solo registros donde el campo de cambio es mayor al último watermark. | La CDS debe exponer un campo fecha/hora (UTC o DATS) y estar anotada con `@Analytics.dataExtraction.delta.byElement.name: 'NombreCampo'` (ej. 'LastChangeDateTime'). |
| **Delta por CDC (Change Data Capture)** | ODP entrega solo inserts/updates/deletes capturados por triggers en tablas subyacentes. | Anotación `@Analytics.dataExtraction.delta.changeDataCapture.automatic: true` en la CDS; la vista debe acceder directamente a las tablas con CDC. |

- **Intervalo de seguridad (timestamp):** SAP suele aplicar un retraso configurable (ej. 30 min) para no perder cambios en vuelo.
- **Limitación:** Si la CDS estándar no tiene campo de cambio ni CDC habilitado, **solo queda Full** para esa vista (o crear una Custom CDS que lo añada, si el equipo SAP puede hacerlo).

### 6.2 Cómo identificar qué estrategia usar por CDS

1. **Revisar la CDS en SAP:** En la definición ABAP, comprobar si existe anotación `@Analytics.dataExtraction.delta.byElement.name` o `@Analytics.dataExtraction.delta.changeDataCapture.automatic`. Si están presentes, la extracción vía ODP puede usar delta. **Herramientas útiles:** SAP GUI (transacción **SE11** – Diccionario de datos ABAP) para ver la definición de la vista CDS y sus anotaciones; **SAP HANA Studio** con acceso de lectura al esquema **SAPHANADB** para consultar tablas, vistas y objetos asociados a las CDS.
2. **Revisar campos expuestos:** Si la vista trae campos como `LastChangeDate`, `LastChangeDateTime`, `CreationDate`, `ChangedAt`, etc., se puede valorar delta por elemento (y, si hace falta, pedir a SAP que añada la anotación en una Custom CDS). En HANA Studio puedes inspeccionar la estructura de la vista materializada o la tabla subyacente para ver qué columnas de fecha/cambio existen.
3. **Ejemplos según tu piloto:**
   - **ISDSALESORDER:** Suele incluir `LASTCHANGEDATE` / `LASTCHANGEDATETIME` → candidata a **delta por elemento** (si la anotación está en la CDS).
   - **I_CUSTOMER_CDS:** Típicamente solo `CREATIONDATE` → sin "last changed" estándar; opciones: **Full** para maestros (volumen moderado) o Custom CDS con campo de cambio si SAP lo habilita.
   - **IMATERIAL:** Maestro; muchas implementaciones solo exponen creación → **Full** es habitual para maestros de material.
   - **IMATDOCITEM, IFIJOURNALENTIT:** Transaccionales; si la CDS expone fecha de documento/posting, se puede usar como watermark para **delta por elemento** (solo si la CDS está anotada para ello).

### 6.3 Estrategia recomendada por tipo de entidad

| Tipo | Recomendación | Notas |
|------|----------------|-------|
| **Maestros (cliente, material, proveedor)** | **Full** en horario de bajo uso (ej. nocturno). | Volumen limitado; Full es simple y evita dependencia de campos de cambio que no siempre existen. |
| **Transaccionales con LASTCHANGEDATE/LASTCHANGEDATETIME en la CDS** | **Delta por elemento.** | Registrar en control `watermark_column` y `updated_at_column`; actualizar `last_watermark_value` / `last_updated_at_value` tras cada ejecución exitosa. |
| **Transaccionales sin campo de cambio en la CDS** | **Full** o **Custom CDS + delta** si SAP lo permite. | Si el volumen es muy alto, valorar con SAP añadir una Custom CDS con delta. |

### 6.4 Registro en tablas de control

- **source_to_bronze_control_sap:** Por cada CDS que se ingesta a Bronze: `load_type` Full o Incremental; si incremental: `watermark_column`, `updated_at_column`, `last_watermark_value`, `last_updated_at_value` (actualizar tras cada run).
- **bronze_to_silver_control_sap:** Por cada flujo Bronze SAP → Silver: `type_load` Full o Incremental; si incremental: mismo uso de watermark/updated_at; el pipeline debe filtrar Bronze por ese valor antes de transformar.

### 6.5 Fallback cuando no hay delta en la CDS

- **Full periódico:** Programar Full (diario o N veces al día) según criticidad y tamaño.
- **Custom CDS (lado SAP):** Si el equipo SAP puede, crear una vista que extienda la estándar y añada un campo de "última modificación" (o que use tablas con CDC) y la anotación correspondiente.
- **Híbrido:** Maestros en Full y transaccionales que soporten delta en Delta; documentar en la matriz de control qué objeto usa qué estrategia.

---

## 7. Plan de implementación sugerido (independiente de la estrategia elegida)

### Fase 1: Preparación

1. **Análisis de mapeo SAP → Silver**
   - Listar entidades Silver actuales (clientes, productos, órdenes de venta, facturas, etc.).
   - Para cada entidad, documentar tablas/vistas CDS SAP equivalentes (I_*, custom CDS); en Fabric el conector SAP Table Application Server requiere buscar por SQL view name.
   - Matriz de mapeo: campo Silver genérico ↔ campo CDS SAP; reglas de transformación (tipos, códigos, nulos).
   - Identificar campos solo en SAP: decisión (nullable, default, nueva columna opcional).
   - Para **tablas QAD con prefijo XX:** ya se aplica tabla genérica en Silver con columnas nullable para campos que existen en un origen y no en el otro (inventario de tablas XX disponible); mantener el mismo criterio al incorporar SAP si alguna entidad XX tiene equivalente en SAP.

2. **Diseño del schema Silver evolutivo**
   - Añadir `source_system` ('QAD' | 'SAP') en todas las tablas Silver que reciban ambas fuentes.
   - Definir clave de negocio unificada (ej. `customer_bk` que en QAD sea id QAD y en SAP sea id SAP; o clave compuesta `(source_system, id_fuente)`).
   - Documentar SCD (tipo I/II) para dimensiones que lo requieran.

3. **Infraestructura**
   - `lh_bronze_sap` ya existe; ampliar extracción según prioridad de entidades. Registrar cada CDS/tabla en **source_to_bronze_control_sap** (source_object, object_type, target_lakehouse, load_type, watermark si incremental).
   - Conectores ya disponibles: SAP Table Application Server (CDS por SQL view name) y SAP HANA Database (schema SAPHANADB); Data Gateway on-premise ya configurado.
   - Definir qué CDS views extraer (lista priorizada); para incremental, documentar en control qué objetos soportan delta (ver sección 6).

### Fase 2: Piloto

1. Elegir **una entidad** (ej. clientes o productos).
2. Implementar flujo completo: SAP → Bronze SAP → Silver (o `lh_silver_sap`) → capa conformada (si aplica) → Gold.
3. Validación:
   - Comparar volúmenes y registros clave QAD vs SAP.
   - Verificar que reportes Gold con datos SAP son coherentes (y, si existe, comparar con reportes estándar SAP).

### Fase 3: Implementación gradual

1. Priorizar entidades por dependencias y criticidad (maestros primero: clientes, productos, proveedores; luego transaccionales: órdenes, facturas).
2. Período en paralelo: Silver recibe QAD (histórico) y SAP (nuevo); Gold (o capa conformada) entrega datos unificados.
3. Reportes y RPAs consumen sin que el usuario tenga que elegir sistema.

### Fase 4: Estabilización

1. Dejar de ingestar QAD a Bronze (solo lectura para histórico).
2. Bronze SAP como fuente primaria.
3. Validación final de reportes y RPAs; optimización de pipelines (particiones, Z-ordering, capacidad).

---

## 8. Matriz de mapeo (ejemplo conceptual)

| Entidad Silver (genérica) | Origen QAD        | Origen SAP (CDS / tabla) | Notas |
|---------------------------|-------------------|---------------------------|--------|
| customer                  | cm_mstr + ad_mstr | I_CUSTOMER / KNA1 + direcciones | Unificar dirección facturación/envío; source_system en Silver. |
| product / material        | Tablas ítem QAD   | I_MATERIAL / MARA         | Códigos de material y unidad de medida distintos; mapeo en Silver. |
| sales_order_header        | Tablas SO QAD     | I_SALESDOCUMENT (o I_SALESORDER si solo OR) | Usar I_SALESDOCUMENT si hay más tipos de documento. |
| sales_order_line          | Líneas SO QAD     | Vistas ítem sobre I_SALESDOCUMENT / VBAP | Número de documento + posición como clave. |

Cada fila debe bajar a nivel de **campo** en tu documento de mapeo real (nombre Silver, nombre SAP, tipo, transformación, nulos).

---

## 9. Gestión de riesgos (resumen)

| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| Mapeo SAP incorrecto | Alto – reportes erróneos | Validación con usuarios funcionales SAP; contraste con reportes estándar SAP; piloto por entidad. |
| Degradación de performance | Medio | Pruebas de carga; particionado (source_system, fecha); Z-ordering; revisar capacidad Fabric. |
| Coste de capacidad Fabric | Bajo | Monitoreo de consumo; optimizar programación y duración de pipelines. |
| Inestabilidad del Silver actual | Alto (Estrategia 1) | En Estrategia 3 no se toca; en Estrategia 1, solo pipelines nuevos para SAP y piloto. |

---

## 10. Resumen de decisión

- **Bronze:** Mantener lh_bronze_qad1, lh_bronze_qad2 y lh_bronze_sap; control vía source_to_bronze_control y source_to_bronze_control_sap.
- **Estructura Silver actual:** Reutilizable como contrato único; es “genérica” en nombres (snake_case, estilo SAP) pero de estructura y normalización tipo QAD (ver 1.3). SAP se mapea a esa misma estructura; extender source_system a todas las tablas que reciban QAD + SAP.
- **Incremental SAP:** Por objeto: maestros en Full; transaccionales con campo de cambio en Delta por elemento cuando la CDS lo soporte; registrar en control (sección 6).
- **Bronze SAP:** Preferible basado en **CDS views** (ODP), no en tablas transaccionales crudas.
- **Estrategia recomendada:** **Estrategia 3** (Silver dual + capa conformada), según criterios de buenas prácticas y uso en migraciones (ver **sección 4**). Alternativa: Estrategia 1 si se prefiere una sola Silver física asumiendo riesgo controlado.
- **Gold:** Sin cambios estructurales; sigue consumiendo una única Silver (unificada o conformada), con datos de QAD y SAP unificados y transparentes para el usuario final.
- **Capa conformada (E3):** Puede empezar como vistas (UNION ALL de tablas homólogas por entidad) para menor esfuerzo; si luego se necesitan reglas SCD o deduplicación, pasar a tablas materializadas alimentadas por un ETL de solo merge.

---

## 11. Árbol de decisión rápida

```
¿Quieres tocar lo menos posible el Silver QAD actual?
├── SÍ → ¿Estás dispuesto a mantener una capa extra (conformación)?
│         ├── SÍ → Estrategia 3 (Silver dual + capa conformada) ✓ Recomendada
│         └── NO → Estrategia 2 (Silver dual; consolidación solo en Gold)
└── NO → ¿Prefieres una sola Silver y asumes riesgo controlado?
          └── SÍ → Estrategia 1 (Silver unificado)
```

---

## 12. Referencia: extracción SAP S/4 HANA (CDS / ODP)

Para implementar Bronze SAP de forma alineada con SAP:

- **Descubrir CDS views:** SAP Business Accelerator Hub (api.sap.com), Fiori app View Browser (F2170), o Eclipse ADT con ABAP Development Tools. Con **SAP GUI** puedes usar la transacción **SE11** (Diccionario de datos ABAP) para consultar la definición de vistas CDS y sus anotaciones de delta; con **SAP HANA Studio** (acceso de lectura al esquema **SAPHANADB**) puedes revisar tablas, vistas y la estructura de los objetos que exponen las CDS.
- **Habilitar extracción:** En vistas custom usar anotaciones `@Analytics.dataExtraction.enabled` y categoría de datos; escenario "Data Extraction" en la app Custom CDS Views.
- **Modos:** Full load para carga inicial; delta cuando el contexto ODP lo soporte (S/4 HANA 2018+).
- **Conectividad:** ODP/ODQ en Fabric (conector SAP si está disponible) o capa intermedia (ej. Azure Data Factory / Fabric Data Pipeline) que consuma ODP y escriba en OneLake (Bronze SAP).

Esto mantiene Bronze SAP estable y facilita que Silver (o `lh_silver_sap`) solo se preocupe del mapeo a tu estructura genérica, no de armar la entidad de negocio desde decenas de tablas transaccionales.
