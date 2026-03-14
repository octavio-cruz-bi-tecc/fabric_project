# Análisis Matriz de Mapeo ERP y CDS Views – Mejoras y propuestas

**Ajustes ya aplicados (ref. solicitud de refinamiento):**
- **Matriz:** En el primer registro de cada grupo (fila `lh_silver_erp`), la columna `source_table` se rellenó con el mismo valor que `target_table` (tabla genérica Silver). Se añadió la columna **Notas_SAP** al final para anotar en filas SAP: CDS alternativa, cabecera+posición, o motivo de vacío.
- **Basic_CDS_View.csv:** Se añadieron las columnas **Tipo carga sugerido** (Full / Delta timestamp), **Tabla subyacente** (tablas SAP de origen) y **Notas**, con valores sugeridos por CDS. El diccionario de campos por CDS se deja para una fase posterior.

---

## 1. Análisis de Matriz_Mapeo_ERP.csv

### 1.1 Estado actual

- **Estructura:** Grupos de 3 (o 4) filas: Silver (target_table + campos genéricos), QAD (source_table + mapeo campos), SAP (source_table = CDS View + mapeo campos SAP). Columnas sap_* al final para campos exclusivos SAP.
- **Filas SAP con CDS asignada:** ~87 tablas Silver tienen una CDS View en `source_table`.
- **Filas SAP sin CDS (source_table vacío):** 68 tablas (listado en la sección 1.3).

### 1.2 Mejoras sugeridas para la matriz

| Mejora | Descripción |
|--------|-------------|
| **Columna “Notas SAP”** | Añadir una columna opcional (ej. `notas_sap` o `cds_alternativa`) en las filas SAP para anotar: CDS alternativa, si requiere 2 CDS (cabecera + posición), o motivo por el que se dejó vacío. |
| **Documentar convención de nombres** | En un README o en la cabecera del CSV, dejar claro que en filas SAP los valores de Campo_XXX son **nombres de campo de la CDS** (tal como aparecen en SAP), no expresiones ni alias. |
| **Revisión campo a campo** | En tablas ya con CDS (ej. IFICLI, IACCDOCITEM), muchos campos siguen vacíos porque el mapeo genérico no aplica (ej. user1, chr01, campos custom). Esos se pueden ir completando manualmente o con un diccionario de campos por CDS (ver sección 4). |
| **Tablas con doble origen** | Para entidades que en SAP son “cabecera + posición” (ej. factura cabecera + ítems), valorar si en la matriz se documenta: (a) una sola fila SAP con la CDS principal y nota de “complementar con CDS_ITEM”, o (b) dos filas SAP (mismo target_table) con distintas source_table. |
| **Consistencia esquema** | En la matriz aparece `lh_bronze_sap_rise`; si en Fabric el lakehouse se llama distinto (ej. `lh_bronze_sap`), unificar el nombre para no confundir en pipelines. |

### 1.3 Tablas Silver sin CDS asignada (68)

Para poder **sugerir o completar** una CDS View en estas tablas se necesita al menos uno de estos insumos:

- **Nombre de la tabla/origen en QAD** (source_table de la fila QAD del mismo grupo): para inferir el dominio (FI, SD, MM, etc.) y buscar una CDS análoga en SAP.
- **Lista corta de campos clave** de la tabla Silver (3–5 campos que definan la entidad): para buscar en S/4 una CDS que exponga datos equivalentes.
- **Uso en Gold:** si la tabla alimenta algún datamart o reporte crítico, priorizar su mapeo; si es solo soporte o legacy, se puede dejar para después.

**Listado de target_table sin CDS (source_table vacío en fila SAP):**

- **Maestros / parámetros genéricos:** accessorial_charge_conditions, analyst_codes, bank_master, countries, currencies (ya con ICurrency en script pero no aplicado en matriz si no está en dict), exchange_rates, format_positions, general_codes, incoterms, payment_terms, standard_texts, units_of_measure.
- **FI / control de pagos:** check_register, payment_batches, payment_cleared_items, parked_journal_entries.
- **CO / presupuesto:** budget_header, budget_line_items, budget_work_center, assignment_items, assignment_complement_items.
- **SD / logística / ventas:** pricing_conditions, sales_account_determinations, sales_employee, customer_materials, customers_comments, freight_master, freight_order, freight_order_items, freight_condition_rates, freight_zones, landed_cost_condition_types, landed_cost_details, return_types, return_type_items, request_return, request_return_items, rejections, rejection_items.
- **MM / inventario:** source_list_header, source_list_items, inventory_status_definitions, inventory_status_movement_controls, material_deviations, material_feasibility, material_feasibility_items1, material_feasibility_items2, cycle_count_document_header, cycle_count_document_items, price_change_request, purchasing_conditions, purchasing_info_records.
- **PP / MRP:** mrp_run_result_items, feasibility_analysis, feasibility_analysis_items.
- **ECP / custom (nómina, organización):** job_titles, payroll_concepts, payroll_control, payroll_groups, payroll_periods, payroll_register, positions, positions_history.
- **Otros:** comments, cross_references, custom_transaction_history, e_documents_history, process_log_history, product_lines, projects, rpa_control, sales_order_parent_child_history, supplier_bank_accounts, supplier_payment_history, tax_code_details, tax_codes, tax_environment_details, tax_environment_master, tax_transaction_details, ticket_master, ticket_detail, user_master, user_details, user_det1, user_det2, user_group_master.

**Qué información adicional ayuda para cada una:**

1. **Tabla QAD (source_table) del mismo grupo**  
   Con el nombre de la tabla en QAD (ej. `XXPER_MSTR`, `AP_MSTR`) se puede buscar en documentación SAP o en tu sistema una CDS equivalente (ej. periodo → ejercicio fiscal; banco → maestro de bancos).

2. **Esquema Silver (Esquema)**  
   Ya está en la matriz (aa, co, ecp, fi, md, mm, sd, etc.). Sirve para acotar el módulo SAP (FI, CO, SD, MM, PP, etc.) al buscar CDS.

3. **Campos clave de la fila Silver (primeros 5–10 de ese grupo)**  
   Con “qué guarda” la tabla (ej. employee_id, concept_id, amount, date) se puede proponer una CDS estándar (ej. nómina, partidas de diario) o indicar que no existe CDS estándar y habría que usar extensión o vista custom.

4. **Prioridad para Gold**  
   Si indicas qué target_table alimentan reportes o datamarts críticos, se puede priorizar: primero completar CDS y mapeo para esas, y dejar el resto como “pendiente de revisión”.

Con esa información se puede:
- ampliar `TARGET_TO_CDS_AND_FIELDS` en `complete_sap_mapping.py` con nuevas target_table → (CDS, mapeo),
- o rellenar a mano en la matriz la columna source_table y, donde aplique, los nombres de campo SAP en las columnas Campo_001, etc.

---

## 2. Campos que faltan en el mapeo SAP

- **Campos custom / extensión (user1, chr01, dec01, etc.):** El script los deja vacíos a propósito. Para mapearlos haría falta saber si en SAP existen campos de usuario o de extensión equivalentes en la CDS (a veces con nombres como `UserField1`, `ExtensionField`, o en tablas de texto/atributos). Esa información suele salir de SE11/SE16 o del diccionario de la CDS.
- **record_id / last_updated_at:** En Silver son de control ETL. En SAP el equivalente suele ser una clave técnica (ej. documento + posición) y `LastChangeDateTime` o similar; ya se sugiere LastChangeDateTime para last_updated_at. record_id puede quedar vacío o documentarse como “clave compuesta SAP” en notas.
- **Campos que dependen de otra entidad:** Por ejemplo “nombre del cliente” en una tabla de documentos: en la CDS suele venir como campo de asociación o texto. Para mapearlos bien conviene tener el listado de campos de la CDS (diccionario por CDS, sección 4).

**Resumen:** Para completar más campos hace falta un **diccionario de datos por CDS** (nombre técnico del campo + descripción breve). Con eso se puede:
- rellenar más celdas de la fila SAP en la matriz, y
- documentar en `complete_sap_mapping.py` mapeos específicos silver_field → sap_field por target_table.

---

## 3. Basic_CDS_View.csv – Revisión y mejoras

### 3.1 Estado actual

- 5 columnas: Módulo, Área Funcional, Nombre Entidad CDS (Data Definition), SQL View Name (Nombre Técnico), Descripción Breve.
- 60 CDS listadas (FI, CO, SD, MM, PP, PM, QM, EWM, Cross).
- Codificación UTF-8 correcta; todas las filas con 5 columnas.

### 3.2 Mejoras sugeridas para Basic_CDS_View.csv

| Mejora | Descripción |
|--------|-------------|
| **Columna “Nombre técnico ABAP”** | Añadir una columna con el nombre de la definición CDS en ABAP (ej. `I_JournalEntryItem` ya está como “Nombre Entidad CDS”; si en tu entorno usas otro nombre técnico o paquete, podría ser una columna extra opcional). |
| **Columna “Tipo carga sugerido”** | Valores como Full / Delta timestamp / Delta CDC, según lo que soporte la CDS (ayuda al registrar en source_to_bronze_control_sap). |
| **Columna “Tabla subyacente / origen”** | Opcional: ej. ACDOCA, BKPF, BSEG para vistas FI; ayuda a quien consulte documentación SAP. |
| **Columna “Notas”** | Opcional: si la CDS requiere filtro por sociedad, o es solo Cloud, o tiene restricciones de uso. |
| **CDS que faltan y podrían añadirse** | Según las tablas sin mapear: vistas de bancos (si existen en tu release), condiciones de precio (SD), listas de fuentes de suministro, lotes de inspección (QM ya está). Se pueden ir añadiendo filas a Basic_CDS_View.csv conforme se vayan identificando en el sistema. |

No es estrictamente necesario modificar ya el CSV; se puede mantener como está y usar el **diccionario de datos por CDS** (sección 4) como complemento.

---

## 4. Propuesta: Diccionario de datos de CDS Views

Objetivo: tener un “diccionario” que permita consultar, por cada CDS View usada en la matriz, **qué campos expone y una breve descripción**, para completar el mapeo Silver ↔ SAP y para futuras consultas.

### 4.1 Opciones de formato

**Opción A – Un archivo por CDS (recomendada para muchas CDS)**  
- Un CSV (o Markdown) por CDS, por ejemplo: `CDS_IFIGLITM.csv`, `CDS_IFICLI.csv`, …
- Ventaja: fácil de mantener y de abrir solo la CDS que interesa.
- Estructura sugerida por archivo:
  - `Campo_CDS` (nombre técnico del campo en la vista)
  - `Tipo_dato` (opcional, ej. DEC, CURR, DATS)
  - `Descripcion` (breve)
  - `Ejemplo_mapeo_Silver` (opcional: nombre del campo Silver si ya se mapeó en la matriz)

**Opción B – Un solo archivo con todas las CDS**  
- Un CSV con columnas: `SQL_View_Name`, `Campo_CDS`, `Tipo_dato`, `Descripcion`, `Ejemplo_mapeo_Silver`.
- Ventaja: una sola tabla para buscar “en qué CDS está este campo”.
- Desventaja: el archivo puede ser muy largo (decenas de CDS × muchas columnas).

**Opción C – Un archivo índice + archivos por módulo**  
- `CDS_Indice.csv`: lista de CDS con SQL View Name, Módulo, enlace al archivo de detalle.
- Carpetas o archivos por módulo: `CDS_FI.csv`, `CDS_MM.csv`, cada uno con las filas de todas las CDS de ese módulo (SQL_View_Name, Campo_CDS, Descripcion, …).

### 4.2 Recomendación práctica

- **Corto plazo:** Añadir a **Basic_CDS_View.csv** las columnas opcionales que quieras (Tipo carga sugerido, Notas) y dejar el resto del contenido como está.
- **Siguiente paso:** Crear el diccionario de campos por CDS. Empezar por **Opción A** para las 10–15 CDS más usadas en tu matriz (IFIGLITM, IFICLI, IFISLI, IACCDOCITEM, ISALESORDER, ISALESORDERITM, IPURCHASEORDER, IPURCHASEORDERIT, IPRODUCT, IMATDOCITEM, IBILLINGDOC, IBUSINESSPART, ICUSTOMER, ISUPPLIER, ICOSTCENTER, ICOMPANYCODE). Cada archivo: `CDS_<SQLViewName>_campos.csv` con columnas: `Campo_CDS`, `Tipo_dato`, `Descripcion`, `Mapeo_Silver_sugerido`.
- **Origen de los datos:** Los nombres y descripciones de campos se pueden obtener desde SAP (SE11, F2 sobre la CDS, o transacción que liste los campos de la vista). Si tienes exportaciones o documentación de las CDS, se pueden rellenar los CSV a partir de ahí; si no, se puede dejar la estructura creada y rellenar de forma incremental.

### 4.3 Uso del diccionario con la matriz

- Al completar una fila SAP en la matriz: consultar el CSV de esa CDS, elegir el campo CDS que corresponda a cada Silver y escribirlo en la columna Campo_001, Campo_002, etc.
- Para tablas sin CDS: si al buscar en SAP encuentras una CDS que encaja, la añades a Basic_CDS_View.csv y creas su `CDS_<Nombre>_campos.csv`; luego actualizas el script o la matriz con esa source_table y, con el diccionario, rellenas los campos.

---

## 5. Resumen de acciones sugeridas

1. **Matriz:** (a) Unificar nombre de lakehouse SAP si aplica; (b) opcionalmente añadir columna de notas/cds_alternativa para filas SAP; (c) completar source_table y campos para las 68 tablas sin CDS usando: tabla QAD del grupo, esquema, campos clave y prioridad Gold.
2. **Información que ayudaría a completar mapeo:** Para cada target_table sin CDS: tabla origen QAD, 3–5 campos clave Silver y si es prioritaria para Gold. Para campos vacíos en tablas ya con CDS: listado de campos de cada CDS (nombre técnico + descripción).
3. **Basic_CDS_View.csv:** Opcionalmente añadir columnas “Tipo carga sugerido” y “Notas”; mantener UTF-8 y 5 columnas obligatorias.
4. **Diccionario CDS:** Crear estructura de archivos “un CSV por CDS” (Campo_CDS, Tipo_dato, Descripcion, Mapeo_Silver_sugerido) para las CDS más usadas; rellenar desde SAP o documentación de forma incremental y usar para completar la matriz y el script de mapeo.

Si indicas por qué tablas sin CDS quieres priorizar (o compartes un listado de tablas QAD por grupo), se puede proponer una CDS concreta para cada una y, si quieres, el contenido inicial de los CSV del diccionario para esas CDS.
