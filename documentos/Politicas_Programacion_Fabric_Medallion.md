# Políticas de programación – Arquitectura Medallion en Microsoft Fabric

**Uso:** Este documento define estándares de nomenclatura, procedimientos de carga y convenciones técnicas para el proyecto de integración SAP/QAD en Microsoft Fabric. Está diseñado para ser utilizado como **skill** o **regla** en Cursor u otros entornos de desarrollo asistido por IA.

**Fuentes:** Manual de trabajo (incorporación de tablas), Nomenclatura Objetos de Fabric, Nomenclatura para Tablas, Estrategia de Migración QAD→SAP, [Microsoft Fabric Medallion Architecture](https://learn.microsoft.com/en-us/fabric/onelake/onelake-medallion-lakehouse-architecture).

---

## 1. Principios generales

- **Claridad (Clarity):** Los nombres deben ser auto-descriptivos. Evita abreviaturas ambiguas.
- **Consistencia (Consistency):** Usa siempre el mismo patrón una vez adoptado.
- **Ordenabilidad (Sortability):** Los nombres deben agruparse lógicamente al ordenarse alfabéticamente.
- **Sin espacios ni caracteres especiales:** Usa los formatos de mayúsculas/minúsculas definidos para separar palabras.
- **Idioma:** Inglés para nombres técnicos y de negocio; español para documentación interna.

---

## 2. Arquitectura Medallion – Capas y propósito

| Capa | Propósito | Formato recomendado (Fabric) |
|------|-----------|------------------------------|
| **Bronze (Raw)** | Datos tal cual llegan; sin transformaciones. Fuente de verdad. | Parquet, Delta Lake o formato original. Preferir Delta para trazabilidad. |
| **Silver (Enriched)** | Limpieza, estandarización, deduplicación, conformación de dimensiones. | Delta Lake obligatorio. |
| **Gold (Curated)** | Modelo dimensional (star/snowflake) para reportes y dashboards. | Delta Lake o Warehouse. |

Cada capa debe residir en su propio Lakehouse (o Warehouse para Gold). Los datos fluyen en una sola dirección: Bronze → Silver → Gold.

---

## 3. Nomenclatura de objetos de Fabric

### 3.1 Workspaces

- **Formato:** `[Environment] - [Function or Domain]`
- **Environment:** `DEV`, `TEST`, `PROD`.
- **Function or Domain:** Propósito principal del workspace, en inglés.

**Ejemplos:**
```
PROD - Data Engineering
TEST - Data Engineering
DEV - Data Engineering
PROD - Gold Finance
PROD - Gold Sales
```

### 3.2 Lakehouse, Warehouse, Dataset, Report, Pipeline, Dataflow

- **Formato:** `[prefix]_[snake_case]`
- **Prefijo:** Abreviatura en minúsculas según el tipo de artefacto.
- **Nombre:** snake_case descriptivo.

**Prefijos:**

| Prefijo | Tipo de artefacto |
|---------|-------------------|
| lh | Lakehouse |
| wh | Warehouse |
| ds | Dataset (Semantic Model) |
| rp | Report (Power BI Report) |
| pl | Pipeline |
| df | Dataflow |

**Ejemplos por capa:**
```
lh_bronze_qad1
lh_bronze_qad2
lh_bronze_sap
lh_silver_erp
lh_control_erp
wh_finance
wh_sales
ds_corporate_finance
rp_income_statement
pl_load_bronze_qad
pl_load_silver_erp
df_conform_customer
```

**Importante:** Los artefactos **no** llevan sufijo de entorno (_DEV, _TEST). El mismo nombre se reutiliza en cada workspace según el entorno.

---

## 4. Nomenclatura de tablas, columnas y esquemas

### 4.1 Capa Bronze (Raw Data)

**Objetivo:** Reflejar el origen de manera fiel. Facilita validación y trazabilidad.

| Elemento | Formato | Casing | Ejemplo |
|----------|---------|--------|---------|
| **Tablas** | Nombre original del sistema fuente o `[source]_[table]` si hay múltiples orígenes | Mantener original (QAD: `_mstr`, `_det`; SAP: nombres técnicos) | `cm_mstr`, `AD_MSTR`, `IMATERIAL`, `I_CUSTOMER_CDS` |
| **Esquemas** | Por origen / sistema | UPPERCASE o Pascal según convención del origen | `QAD`, `SAPHANADB` |
| **Columnas** | Nombre original del campo | Mantener original; snake_case si se normaliza | `cm_addr`, `pt_part`, `mandt`, `bukrs`, `MANDT` |

**Proyecto actual:**
- QAD: esquema `QAD`, tablas como `CM_MSTR`, `AD_MSTR`, `DSD_DET`, etc.
- SAP: esquema `SAPHANADB`, tablas desde CDS views: `IMATERIAL`, `I_CUSTOMER_CDS`, `ISDSALESORDER`, etc.

### 4.2 Capa Silver (Conformed Data)

**Objetivo:** Datos limpios, unificados y agnósticos al origen. Lenguaje de negocio. Alineado a terminología SAP en inglés (incluso para QAD).

| Elemento | Formato | Casing | Ejemplo |
|----------|---------|--------|---------|
| **Tablas** | Nombre de entidad de negocio | **snake_case** | `sales_order`, `invoices`, `customers`, `chart_of_accounts` |
| **Esquemas** | Por área funcional (2–3 letras) | minúsculas | `sd`, `fi`, `co`, `mm`, `pp`, `md`, `ecp`, `qm`, `dbo` |
| **Columnas** | Nombres de negocio claros | **snake_case** | `customer_id`, `order_date`, `sales_amount`, `company_code`, `source_system` |

**Campos obligatorios en tablas multi-origen (QAD + SAP):**
- `company_code`: Sustituye al dominio QAD; código de sociedad/empresa.
- `source_system`: `'QAD'` o `'SAP'` según origen.

**Ejemplos de tablas Silver:**
```
sd.sales_order
sd.invoices
sd.invoice_items
fi.journal_posting_items
mm.purchase_order
md.customers
```

### 4.3 Capa Gold (Curated / Dimensional Model)

**Objetivo:** Máxima claridad para analistas y usuarios finales. Modelo estrella evidente.

| Elemento | Formato | Casing | Ejemplo |
|----------|---------|--------|---------|
| **Tablas dimensión** | `dim_[concepto]` | snake_case | `dim_customer`, `dim_product`, `dim_date` |
| **Tablas hechos** | `fact_[proceso]` | snake_case | `fact_sales`, `fact_inventory` |
| **Columnas** | snake_case descriptivo | snake_case | `customer_key`, `product_key`, `sales_amount` |

**Claves:**
- **Surrogate Key:** `[concepto]_key` (ej. `customer_key`, `product_key`, `date_key`). Clave técnica entera.
- **Business Key:** `[concepto]_id` (ej. `customer_id`, `product_id`). Código del sistema origen.
- **Foreign Keys en Fact:** Deben coincidir exactamente con el nombre de la Surrogate Key de la dimensión (ej. `customer_key`, `product_key`).

**Ejemplos Gold:**
```
dim_customer
dim_product
dim_date
fact_sales
fact_inventory
```

### 4.4 Resumen por capa

| Capa | Tablas | Columnas | Esquemas |
|------|--------|----------|----------|
| Bronze | Original fuente | Original fuente | QAD, SAPHANADB, etc. |
| Silver | snake_case | snake_case | sd, fi, co, mm, pp, md, ecp, qm, dbo |
| Gold | dim_*, fact_* | snake_case | (según diseño) |

---

## 5. Nomenclatura de vistas, procedimientos y funciones

| Tipo | Prefijo | Formato | Ejemplo |
|------|---------|---------|---------|
| Vista | vw | `vw_<origen>_<área>_<nombre>` | `vw_qad_finance_accounts_master`, `vw_silver_sd_sales_summary` |
| Procedimiento almacenado | sp | `sp_<acción>_<área>_<objeto>` | `sp_load_finance_invoice_details` |
| Función escalar | fn | `fn_<resultado>` | `fn_get_last_day_of_month`, `fn_calculate_tax_amount` |
| Función table-valued | fn | `fn_<resultado>` | `fn_get_employee_hierarchy`, `fn_sales_permission_predicate` |

---

## 6. Procedimientos de incorporación de tablas

### 6.1 Campos clave a identificar en cada tabla

| Atributo | Relevancia | Ejemplos |
|----------|------------|----------|
| Campo incremental | Permite carga incremental (nuevos/modificados) | `PROGRESS_RECID`, `UPDATED_AT`, `LastChangeDateTime` |
| Fecha creación/modificación | Alternativa si no hay ID incremental | `CREATED_ON`, `MODIFIED_DT` |
| Clave primaria estable | Base para deduplicación | `ORDER_ID`, `company_code + doc_num` |
| Volumen diario estimado | Define viabilidad Full vs Incremental | <100k, 100k–500k, >1M |
| Frecuencia de cambio | Define ventana de carga | Alta (minutos), Media (diaria), Baja (semanal) |
| Nivel de criticidad | Priorización de desarrollo y monitoreo | Alta (KPIs, regulatorios), Media (seguimiento), Baja (referenciales) |

### 6.2 Clasificación de escenarios y estrategia de carga

| Escenario | Descripción | Estrategia recomendada |
|-----------|-------------|------------------------|
| **A. Transaccionales con campo incremental** | Campo RECID, timestamp o fecha modificación | Carga incremental con MERGE (PySpark). Registrar en control (watermark). |
| **B. Sin incremental, PK estable** | Clave primaria única pero sin fechas | Carga completa con deduplicación por PK. Viable si volumen manejable. |
| **C. Maestros pequeños o estáticos** | Catálogos, bajo volumen | Sobrescritura programada (diaria/semanal). |
| **D. Tablas grandes sin incremental ni PK** | Logs, historiales legacy, IoT | Snapshot particionado (por fecha/lote); evitar overwrite completo. |

### 6.3 Viabilidad Overwrite vs volumen diario

| Registros/día | ¿Overwrite viable? | Acción recomendada |
|---------------|--------------------|--------------------|
| < 100k | Sí | Sobrescritura directa |
| 100k – 500k | Condicional | Overwrite si columnas ligeras; evitar JSON/arrays |
| 500k – 1M | No recomendable | Usar MERGE o partición |
| > 1M | No viable | Snapshot particionado; orquestación robusta |

### 6.4 Procedimiento carga incremental

1. Registrar tabla en **IncrementalLoadControl** (o equivalente en `source_to_bronze_control` / `bronze_to_silver_control`) con `last_loaded_value = NULL`.
2. Lookup en pipeline: obtener `last_loaded_value` máximo.
3. Filtro en origen: `WHERE incremental_field > @last_loaded_value`.
4. Escritura en Bronze/Silver: Delta Table con **MERGE** (PySpark).
5. Actualizar control con nuevo `last_loaded_value` y `updated_at`.

### 6.5 Procedimiento carga completa (Overwrite)

1. Evaluar volumen y frecuencia.
2. Elegir método:
   - **TRUNCATE + INSERT** (SQL DW).
   - **WRITE MODE = overwrite** (Delta Lake / PySpark).
3. Ejecutar en ventana de baja actividad (ej. nocturna).
4. Verificar integridad (conteos, totales vs origen).

### 6.6 Ventanas de carga sugeridas

| Frecuencia | Ejemplos | Ventana sugerida |
|------------|----------|------------------|
| Near realtime | APIs, logs | ≤ 1 hora; 24/7 |
| Diaria | Ventas, inventarios | 1× noche; 01:00–03:00 |
| Semanal | Catálogos | Lunes; 03:00–04:00 |
| Mensual | Históricos | 1× mes; domingo |

---

## 7. Tablas de control (lh_control_erp)

| Tabla | Uso |
|-------|-----|
| `source_to_bronze_control` | QAD → Bronze: target_layer, watermark, load_type |
| `source_to_bronze_control_sap` | SAP → Bronze: source_object, object_type, target_lakehouse |
| `bronze_to_silver_control` | Bronze QAD → Silver: type_load, watermarks |
| `bronze_to_silver_control_sap` | Bronze SAP → Silver: source/target lakehouse, type_load |
| `bronze_to_silver_sql_control` | Flujos Silver basados en SQL/vistas |
| `silver_to_gold_control` | Silver → Gold: surrogate_key, business_keys |
| (go-live) | company_code + fecha go-live SAP por empresa |

Cada pipeline/entidad debe registrarse en la tabla de control correspondiente. Campos típicos: `load_type` / `type_load` (Full/Incremental), `watermark_column`, `last_watermark_value`, `updated_at_column`, `last_updated_at_value`.

---

## 8. Convenciones específicas del proyecto (QAD + SAP)

### 8.1 QAD

- **Clave técnica:** `PROGRESS_RECID` en todas las tablas.
- **Dominio/empresa:** Campo con sufijo `_DOMAIN` (ej. `PO_DOMAIN`, `AD_DOMAIN`). En Silver se mapea a `company_code`.
- **Incremental:** Tabla **UPDT_LOG** en Oracle; triggers por tabla escriben en UPDT_LOG. El ETL incremental usa UPDT_LOG para saber qué registros refrescar.

### 8.2 SAP

- **Extracción:** Preferible **CDS views** (no tablas transaccionales crudas). Anotaciones `@Analytics.dataExtraction.enabled`.
- **Incremental:** Por objeto: Full si la CDS no tiene anotación delta; Delta por elemento (`delta.byElement.name`) o CDC (`changeDataCapture.automatic`) si está disponible.
- **Esquema Bronze:** `SAPHANADB`; nombres de vistas CDS como en SAP (ej. `IMATERIAL`, `I_CUSTOMER_CDS`, `ISDSALESORDER`).

### 8.3 Tablas custom (prefijo XX en QAD)

- Estructura puede diferir entre `lh_bronze_qad1` y `lh_bronze_qad2`.
- En Silver: **una sola tabla genérica** por entidad XX con columnas nullable para compensar campos que existen en un origen y no en el otro.

---

## 9. Buenas prácticas Microsoft Fabric y Medallion

- **Bronze:** Mantener datos en formato original cuando sea posible; usar Delta Lake para trazabilidad. Para orígenes en OneLake/ADLS/S3, preferir **shortcuts** en lugar de copiar.
- **Silver y Gold:** Usar **Delta Lake** obligatoriamente (ACID, time travel, MERGE).
- **Particionado:** En Bronze, particionar por fecha si la ingesta es frecuente. En Silver y Gold, considerar **Liquid Clustering** en lugar de partición para optimizar consultas.
- **Tamaño de archivos:** Objetivo ~1 GB por archivo para mejor rendimiento.
- **Historial Delta:** Retener solo el período necesario; usar VACUUM para liberar espacio.
- **Workspaces:** Crear cada Lakehouse en su propio workspace cuando sea posible para mejor gobernanza.

---

## 10. Guía para uso en Cursor (Skill / Regla)

### 10.1 Cuándo aplicar estas políticas

- Crear o modificar **tablas** en Bronze, Silver o Gold.
- Crear o modificar **pipelines**, **notebooks**, **dataflows** o **artefactos** de Fabric.
- Nombrar **columnas**, **esquemas**, **vistas**, **procedimientos** o **funciones**.
- Diseñar **ETL** (estrategia Full vs Incremental, registro en control).
- Documentar **mapeos** QAD/SAP o entidades multi-origen.

### 10.2 Instrucciones para el modelo

Al generar código o diseño para este proyecto:

1. **Nomenclatura:** Respetar snake_case en Silver y Gold; mantener nombres de origen en Bronze.
2. **Campos obligatorios Silver (multi-origen):** Incluir `company_code` y `source_system` donde aplique.
3. **Tablas de control:** Registrar cada flujo en la tabla de control correspondiente (source_to_bronze, bronze_to_silver, etc.).
4. **Estrategia de carga:** Elegir Full vs Incremental según el escenario (A, B, C, D) y el volumen.
5. **Convenciones QAD:** Usar `PROGRESS_RECID`, mapear `*_DOMAIN` a `company_code`.
6. **Convenciones SAP:** Usar CDS views; no tablas transaccionales crudas; documentar Full vs Delta por CDS.
7. **Prefijos artefactos:** lh_ (Lakehouse), wh_ (Warehouse), pl_ (Pipeline), df_ (Dataflow), vw_ (vista), sp_ (stored proc), fn_ (función).

### 10.3 Ejemplos de prompts de referencia

- *"Crea una tabla Silver para X siguiendo las políticas de nomenclatura del proyecto."*
- *"Define el flujo de carga incremental para la tabla Y según el manual de incorporación."*
- *"Nombra el pipeline que carga Bronze SAP según las convenciones de objetos."*
- *"Asegúrate de incluir company_code y source_system en la tabla Silver Z."*

---

## 11. Resumen ejecutivo

| Área | Regla principal |
|------|-----------------|
| **Workspaces** | `[ENV] - [Domain]` (ej. PROD - Data Engineering) |
| **Lakehouse** | `lh_[layer]_[origen/dominio]` (ej. lh_bronze_sap, lh_silver_erp) |
| **Bronze** | Nombres originales del origen; esquemas QAD, SAPHANADB |
| **Silver** | snake_case tablas y columnas; esquemas sd, fi, co, mm, pp, md, ecp, qm; company_code, source_system |
| **Gold** | dim_*, fact_*; surrogate keys *_key; FKs con mismo nombre que la dimensión |
| **Vistas** | vw_<origen>_<área>_<nombre> |
| **Pipelines** | pl_<acción>_<origen/área> |
| **Carga** | Incremental si hay campo; MERGE en Delta; registro en control; Overwrite según volumen |

---

*Documento generado a partir del Manual de trabajo, Nomenclatura Objetos de Fabric, Nomenclatura para Tablas, Estrategia de Migración QAD→SAP y documentación Microsoft Fabric. Actualizar cuando cambien las convenciones del proyecto.*
