# Plan de capacitación e inducción – Integración SAP en arquitectura Medallion (Fabric)

**Público:** Nuevo integrante del equipo (p. ej. Data Engineer).  
**Objetivo:** Que en 2–3 semanas comprenda el proyecto, la arquitectura, los documentos clave y las tareas en curso, y esté en condiciones de contribuir en ETL SAP y BAU.

**Documentos de referencia:**  
[Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md](./Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md), [Plan_de_Accion_Integracion_SAP_Fabric.md](./Plan_de_Accion_Integracion_SAP_Fabric.md), [Analisis_Matriz_y_CDS_Propuestas.md](./Analisis_Matriz_y_CDS_Propuestas.md), avances semanales en `avances semanales/`.

---

## 1. Día 1–2: Contexto del proyecto y del negocio

### 1.1 Qué hacemos y por qué

- **Objetivo:** Incorporar datos de **SAP S/4 HANA Cloud Private Edition** en la arquitectura de datos que hoy consume **QAD MFG**, para que reportes y RPA consuman **QAD + SAP** de forma unificada, sin que el usuario elija sistema.
- **Arquitectura:** Medallion en **Microsoft Fabric**: Bronze → Silver → Gold.
- **Estrategia elegida:** **Estrategia 3** (Silver dual + capa conformada): no se toca el Silver QAD; se crea `lh_silver_sap` con el mismo “contrato” y una capa conformada (vistas UNION ALL) que Gold sigue consumiendo como un solo origen.

### 1.2 Cronograma de go-live SAP (importante)

| Bloque | Fecha go-live |
|--------|----------------|
| 1.er bloque financieras | Febrero 2026 (ya en operación) |
| **SEL** | **Abril 2026** (~1 mes desde hoy) |
| STU + 2.º bloque financieras | Mayo 2026 |
| SCO + último bloque financieras | Junio 2026 |

Las **3 manufactureras** (SEL, SCO, STU) son el foco de datamarts y reportes; el piloto y las entidades críticas se priorizan para **SEL**.

### 1.3 Lectura obligatoria (Día 1–2)

- **Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md**: al menos secciones 1 (Situación actual), 2 (QAD vs SAP), 3 (las 3 estrategias), 4 (Recomendación E3), 6 (incremental SAP) y 12 (referencia extracción CDS/ODP).
- **Plan_de_Accion_Integracion_SAP_Fabric.md**: completo (fases 0–5, roles, riesgos, próximos pasos).

---

## 2. Día 3–4: Arquitectura técnica

### 2.1 Capas y lakehouses

| Capa | Lakehouses / contenido | Tu foco |
|------|------------------------|---------|
| **Bronze** | `lh_bronze_qad1` (SCO, SEL), `lh_bronze_qad2` (PS, STU, SUS, HOS, IZD, IMA), `lh_bronze_sap` (CDS en SAPHANADB) | Conocer `lh_bronze_sap` y qué CDS se ingesta. |
| **Silver** | `lh_silver_erp` (hoy solo QAD); en E3 se añade **lh_silver_sap** (mismo contrato que Silver, `source_system='SAP'`) | Entender contrato: snake_case, inglés, `company_code`, `source_system`. |
| **Conformada** | Vistas (o tablas) UNION ALL de Silver QAD + lh_silver_sap por entidad; Gold consume solo de aquí. | Saber que Gold no toca QAD ni SAP por separado. |
| **Gold** | Datamarts y vistas para reportes y RPA. | No modificar sin alineación con Architect. |

### 2.2 Tablas de control (lh_control_erp)

- **source_to_bronze_control** / **source_to_bronze_control_sap**: orígenes → Bronze (watermark, load_type Full/Incremental).
- **bronze_to_silver_control** / **bronze_to_silver_control_sap**: Bronze → Silver (type_load, watermarks).
- **silver_to_gold_control**: Silver → Gold (surrogate_key, business_keys).
- **Tabla go-live:** `company_code` + fecha de go-live SAP por empresa (para reportes “actuales”).

Debe quedar claro: cada pipeline/entidad se registra en la tabla de control que corresponda; Full vs Incremental se define por objeto.

### 2.3 Convenciones clave

- **QAD:** `PROGRESS_RECID`, dominio con sufijo `_DOMAIN`; incremental vía **UPDT_LOG** (triggers en Oracle).
- **SAP:** Extracción vía **CDS views** (no tablas transaccionales crudas); incremental cuando la CDS tenga anotación delta (por elemento o CDC).
- **Silver unificado:** `company_code` (reemplaza dominio QAD), `source_system` ('QAD' | 'SAP'); estructura “estilo QAD” como contrato para mapear SAP.

### 2.4 Conectividad SAP

- Data Gateway on‑premise, SAP HANA Connector / HANA Database Client.
- En Fabric: conectores **SAP Table Application Server** y **SAP HANA Database** (esquema SAPHANADB).
- CDS piloto ya en Bronze: IMATERIAL, I_CUSTOMER_CDS, ISDSALESORDER, IMATDOCITEM, etc.

---

## 3. Día 5–6: Mapeo SAP ↔ Silver y CDS

### 3.1 Matriz de mapeo

- **Ubicación:** Matriz de mapeo ERP (por ejemplo `Matriz_Mapeo_Final_ERP_v2.xlsx` o el CSV/artefacto que use el equipo).
- **Estructura:** Por entidad Silver: filas para Silver genérico, QAD (origen y campos) y SAP (CDS/origen y campos). Campo Silver ↔ campo SAP.
- **Objetivo:** Saber qué CDS corresponde a cada tabla Silver y qué columna SAP mapea a cada columna Silver.

### 3.2 Documento Analisis_Matriz_y_CDS_Propuestas.md

- **68 tablas Silver** aún sin CDS asignada; se completan con: tabla QAD del grupo, esquema, campos clave y prioridad para Gold.
- **Basic_CDS_View.csv** (o equivalente): lista de CDS con módulo, SQL view name, tipo de carga sugerido (Full/Delta).
- **Diccionario de CDS:** Propuesta de “un archivo por CDS” con campos (Campo_CDS, Tipo_dato, Descripción, Mapeo_Silver) para completar la matriz y los scripts.

### 3.3 Conceptos SAP que debe dominar

- **CDS View:** Vista de negocio en S/4; preferible extraer CDS (con anotaciones de extracción) en lugar de tablas crudas.
- **Full vs Delta:** Delta = solo cambios (por timestamp o CDC); si la CDS no tiene anotación, solo Full. Revisar sección 6 del documento de estrategia.
- **Anotaciones:** `@Analytics.dataExtraction.enabled`, delta por elemento (`delta.byElement.name`) o CDC (`changeDataCapture.automatic`).

---

## 4. Día 7–10: Fases del plan y rol del nuevo integrante

### 4.1 Fases actuales (Plan de acción)

- **Fase 0 (2–3 sem):** Cierre estrategia, lista de entidades, tabla go-live, plan `source_system`.
- **Fase 1 (4–5 sem):** Mapeo SAP→Silver, diseño lh_silver_sap y capa conformada, control Full/Delta, ampliar Bronze SAP para piloto.
- **Fase 2 (2–3 sem):** Piloto una entidad (Bronze SAP → lh_silver_sap → vista conformada → validación); definir patrón estándar.
- **Fase 3 (8–12 sem):** Rollout entidades para manufactureras (SEL, SCO, STU); prioridad para SEL (go-live abril).
- **Fase 4–5:** Go-live SEL, luego STU/SCO y financieras; estabilización.

**Situación actual (avance semanal):** Estrategia cerrada; preparación Fase 0; Fase 1 en arranque (matriz de mapeo y revisión CDS/control). Piloto y entidades para SEL son prioridad.

### 4.2 Rol del nuevo Data Engineer

- **Principal:** Réplica del patrón del piloto a más entidades (ETL Bronze SAP → lh_silver_sap, vistas conformadas, registro en control).
- **También:** Pipelines, notebooks, mantenimiento de artefactos; soporte a vistas Gold y RPA (BAU).
- **Coordinación:** Con Data Architect en mapeos y estándares; con el otro Data Engineer en reparto de entidades y BAU.

### 4.3 Actividades BAU (en paralelo)

- Mantenimiento Medallion (Bronze QAD, Silver, Gold).
- Migración de vistas para RPA (Oracle → Fabric).
- Soporte a vistas Gold y RPA ya migradas.
- Mejora continua de pipelines y notebooks.

El tiempo del equipo se reparte: parte a integración SAP (~40–50%) y parte a BAU; los plazos del plan asumen esa dedicación.

---

## 5. Semana 2: Herramientas y primeros entregables

### 5.1 Accesos y herramientas

- [ ] Acceso a **Microsoft Fabric** (workspace, lakehouses lh_bronze_sap, lh_silver_erp, lh_control_erp).
- [ ] Acceso a documentación interna (repositorio del proyecto, carpetas de estrategia, plan de acción, matriz, avances).
- [ ] Conocer cómo se ejecutan pipelines (programación, triggers) y dónde están los notebooks de ETL Bronze→Silver.
- [ ] Si aplica: acceso a SAP (solo lectura) o a documentación de CDS (api.sap.com, Basic_CDS_View, diccionarios por CDS).

### 5.2 Patrón “cómo agregar una entidad SAP”

Tras el piloto (Fase 2) debe existir una guía corta que incluya:

1. Dar de alta/verificar la CDS en Bronze (y en source_to_bronze_control_sap).
2. Implementar ETL Bronze SAP → lh_silver_sap (notebook/pipeline) según matriz de mapeo; `source_system`, `company_code`.
3. Crear vista conformada (UNION de Silver QAD y lh_silver_sap para esa entidad).
4. Registrar en bronze_to_silver_control_sap.
5. Prueba básica (volumen, muestreo, reporte Gold si aplica).

El nuevo integrante debe leer esa guía y, si ya existe, hacer una entidad de prueba siguiendo el patrón (con revisión).

### 5.3 Primeras tareas sugeridas (con el líder técnico)

- Revisar la **lista de entidades prioritarias** (Fase 0) y la **matriz** para 2–3 entidades asignadas.
- Revisar **source_to_bronze_control_sap** y **bronze_to_silver_control_sap**: qué objetos están dados de alta y con qué load_type/watermark.
- Shadowing: asistir a una ejecución/revisión de pipeline Bronze→Silver (QAD o SAP) y a una revisión de vista conformada o Gold.

---

## 6. Semana 3: Autonomía y profundización

### 6.1 Objetivos

- Poder implementar una entidad nueva (o una variante) siguiendo el patrón, con revisión de código/mapeo.
- Entender qué entidades son críticas para **SEL** (abril) y cuáles pueden esperar.
- Conocer las **68 tablas sin CDS** y el proceso para proponer/completar CDS (con Architect o con ABAP).

### 6.2 Temas opcionales según perfil

- **Incremental SAP:** Cómo se define Full vs Delta por CDS; cómo se usa watermark en control y en pipeline.
- **Tablas XX (custom QAD):** Tabla genérica en Silver con columnas nullable cuando un origen no tiene el campo.
- **RPA y vistas Gold:** Cómo se usan las vistas que el equipo mantiene; impacto de añadir `source_system` y company_code.

---

## 7. Checklist de inducción (resumen)

| # | Actividad | Responsable | Estado |
|---|-----------|-------------|--------|
| 1 | Leer estrategia (secciones indicadas) y plan de acción completo | Nuevo integrante | |
| 2 | Leer Analisis_Matriz_y_CDS_Propuestas y ubicar matriz de mapeo | Nuevo integrante | |
| 3 | Revisar avance semanal reciente y próxima reunión de equipo | Nuevo integrante | |
| 4 | Recibir acceso Fabric (workspace, lakehouses, pipelines) | Líder / IT | |
| 5 | Sesión técnica: recorrido Bronze SAP, Silver, control tables, convenciones | Data Engineer actual / Architect | |
| 6 | Revisar tabla go-live y fechas por company_code | Nuevo integrante | |
| 7 | Leer (o redactar con el equipo) la guía “cómo agregar una entidad SAP” | Nuevo integrante | |
| 8 | Shadowing: pipeline Bronze→Silver y vista conformada | Nuevo integrante | |
| 9 | Asignar 1–2 entidades o tareas de control/matriz para primera entrega con revisión | Architect / Líder | |
| 10 | Introducción a BAU (RPA, Gold, mantenimiento) según asignación | Equipo | |

---

## 8. Documentos y ubicaciones de referencia

| Documento | Contenido |
|-----------|-----------|
| **Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md** | Contexto, arquitectura, QAD vs SAP, 3 estrategias, E3, incremental SAP, plan impl., riesgos. |
| **Plan_de_Accion_Integracion_SAP_Fabric.md** | Fases 0–5, tiempos, roles, riesgos, próximos pasos. |
| **Analisis_Matriz_y_CDS_Propuestas.md** | Estado de la matriz, 68 tablas sin CDS, Basic_CDS_View, diccionario CDS. |
| **avances semanales/** (Avance_06032026.md y siguientes) | Frentes de avance, incorporación nuevo integrante, próximos pasos. |
| Matriz de mapeo (Excel/CSV) | Mapeo entidad Silver ↔ QAD ↔ SAP (CDS y campos). |
| Basic_CDS_View.csv (o equivalente) | Lista de CDS por módulo, SQL view name, tipo de carga. |

---

*Documento generado para la incorporación de nuevo integrante al equipo de integración SAP en arquitectura Medallion (Fabric). Actualizar según cambios en fases, roles o documentación del proyecto.*
