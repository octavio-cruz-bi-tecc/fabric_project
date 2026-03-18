# Plan de acción detallado – Integración SAP en Fabric

> **Versión:** 1.1 · **Fecha de corte:** 17-Mar-2026
> **Archivo complementario:** [`Plan_Accion_SAP_Fabric_Gantt.xlsx`](Plan_Accion_SAP_Fabric_Gantt.xlsx) (Gantt visual para comité directivo)

Este documento es el cronograma detallado derivado de la presentación *Estrategia y plan de acción – Integración SAP en Fabric*. Explota cada fase en **actividades concretas** con **entregables claros**, **duración estimada** y **fechas tentativas**, para seguir y ejecutar la integración SAP S/4 HANA en la arquitectura Medallion bajo la **Estrategia 3: Silver dual + capa conformada**.

**Referencias:**
- [`Presentacion_Estrategia_Plan_SAP_Fabric.html`](Presentacion_Estrategia_Plan_SAP_Fabric.html) — sección Vista de cronograma
- [`Plan_de_Accion_Integracion_SAP_Fabric.md`](Plan_de_Accion_Integracion_SAP_Fabric.md) — detalle de equipo, riesgos y próximos pasos
- [`Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md`](Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md) — contexto estratégico completo

---

## ⚠️ Alerta de calendario

| Empresa | Go-live SAP | Fase que la cubre |
|---------|-------------|-------------------|
| SEL     | **Abril 2026** | Fase 4 |
| STU     | **Mayo 2026**  | Fase 5 |
| SCO     | **Junio 2026** | Fase 5 |
| 1.er bloque financieras | Feb 2026 | Ya en producción en SAP |
| 2.º bloque financieras  | Mayo 2026 | Fase 5 |
| Último bloque financieras | Junio 2026 | Fase 5 |

**Con duraciones mínimas y trabajo en paralelo, la cadena Fase 0 → Fase 4 cabe en ~10–11 semanas desde hoy (17-Mar-2026), con go-live SEL a finales de mayo / inicio de junio.** Si el objetivo es Abril, se requiere **compresión agresiva** (solapamiento de Fase 1 y Fase 2, trabajo dedicado) y/o ajuste del alcance del piloto.

---

## Vista de cronograma

| Fase | Nombre | Duración | Inicio tentativo | Fin tentativo | Hito |
|------|--------|----------|-----------------|--------------|------|
| 0 | Cierre estrategia | 1 sem | 17-Mar-2026 | 21-Mar-2026 | Priorización lista |
| 1 | Mapeo y diseño | 3 sem | 24-Mar-2026 | 11-Apr-2026 | Diseño y matriz listos |
| 2 | Piloto (1 entidad) | 1.5 sem | 14-Apr-2026 | 24-Apr-2026 | Patrón replicable |
| 3 | Rollout entidades Empresas TECC | 5 sem | 27-Apr-2026 | 30-May-2026 | Vistas listas para SEL |
| 4 | Go-live SEL | 1 sem | 01-Jun-2026 | 07-Jun-2026 | SEL en producción con SAP |
| 5 | STU + SCO + Bloques financieras | 3.5 sem | 08-Jun-2026 | 20-Jun-2026 | Transición cerrada |
| **Total** | | **~14 sem** | **17-Mar-2026** | **20-Jun-2026** | |

> Las fechas son **tentativas** con duraciones mínimas. El rango realista es 15–17 semanas. Ver [`Plan_Accion_SAP_Fabric_Gantt.xlsx`](Plan_Accion_SAP_Fabric_Gantt.xlsx) para el Gantt visual.

---

## Fase 0: Cierre estrategia — 1 semana (17-Mar al 21-Mar-2026)

**Objetivo:** Estrategia adoptada formalmente, lista de entidades que alimentan las vistas Gold (reportes y RPAs) para las Empresas TECC, y plan de extensión de `source_system` en Silver.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **0.1** | Formalizar adopción Estrategia 3 | Revisar y validar con stakeholders la adopción de Estrategia 3 (Silver dual + conformada) y este plan de acción. Documentar ajustes si aplica. | Acta/OK o ajustes al plan documentados | 3 |
| **0.2** | Definir lista priorizada de entidades Silver | Identificar entidades Silver que alimentan vistas Gold (reportes y RPAs) para SEL, SCO, STU. **Criterio de priorización:** maestros primero (clientes, materiales, proveedores), luego transaccionales (órdenes venta, facturas, albaranes). | Lista priorizada de entidades con orden de implementación | 3 |
| **0.3** | Identificar tablas con/sin `source_system` + plan extensión | Revisar qué tablas Silver ya tienen `source_system` y cuáles no. Definir plan de extensión faseado sin romper pipelines QAD existentes. | Lista de tablas + plan de cambio (con prioridad y dependencias) | 2 |

**Entregable de fase:** Lista de entidades priorizada + plan de extensión de `source_system`.

---

## Fase 1: Mapeo y diseño — 3 semanas (24-Mar al 11-Apr-2026)

**Objetivo:** Matriz de mapeo SAP → Silver por entidad; criterio Full/Incremental por CDS; diseño explícito de `lh_silver_sap` y de la capa conformada; Bronze SAP ampliado para el piloto.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **1.1** | Matriz de mapeo por entidad (CDS ↔ Silver) | Por cada entidad priorizada: identificar la CDS SAP equivalente usando SE11 / HANA Studio (SQL View Name para el conector SAPHANADB). Mapear campo a campo (Silver ↔ SAP): nombres, tipos, nulos y reglas de transformación. Incluir `source_system = 'SAP'` y `company_code` desde MANDT o equivalente. | Matriz de mapeo por entidad (Excel o Markdown, una hoja por entidad) | 7 |
| **1.2** | Full vs. Incremental + registro en `source_to_bronze_control_sap` | Por cada CDS: revisar si expone campo de última modificación o anotación delta. Definir Full o Incremental. Registrar `load_type` y `watermark_column` en `source_to_bronze_control_sap`. | Control SAP actualizado; nota breve por objeto con justificación | 4 |
| **1.3** | Diseño de `lh_silver_sap` | Definir tablas y columnas de `lh_silver_sap` con **mismo contrato** que Silver QAD (nombres snake_case en inglés, tipos, claves). Incluir `source_system`, `company_code`, `last_updated_at`, `record_id`. | Documento de diseño `lh_silver_sap` (lista de tablas + columnas por entidad) | 3 |
| **1.4** | Diseño de la capa conformada | Definir vistas `UNION ALL` por entidad (`lh_silver_qad` + `lh_silver_sap`). Indicar: nombres, uso de filtro de go-live por `company_code`, y si alguna entidad requiere tabla materializada en lugar de vista por volumen/rendimiento. | Especificación capa conformada (vistas vs. tablas materializadas; nombres definitivos) | 2 |
| **1.5** | Ampliar `lh_bronze_sap` con CDS del piloto | Incluir en `lh_bronze_sap` las CDS necesarias para la entidad piloto de Fase 2. Registrar en `source_to_bronze_control_sap`. Validar conectividad con Data Gateway. | Pipelines / artefactos Source → Bronze SAP para el piloto; control actualizado | 3 |

**Entregable de fase:** Diseño y matriz listos (documentos de diseño + control SAP actualizado).

---

## Fase 2: Piloto (1 entidad) — ~1.5 semanas (14-Apr al 24-Apr-2026)

**Objetivo:** Una entidad de punta a punta (Bronze SAP → `lh_silver_sap` → capa conformada → validación), con patrón documentado y replicable para las siguientes entidades.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **2.1** | ETL Bronze SAP → `lh_silver_sap` (entidad piloto) | Implementar notebook/pipeline parametrizado para la entidad piloto: aplicar mapeo de la matriz, asignar `source_system = 'SAP'` y `company_code`. Registrar tarea en `bronze_to_silver_control_sap`. Usar retry con backoff exponencial. | Notebook/pipeline operativo + tabla creada en `lh_silver_sap` | 4 |
| **2.2** | Vista conformada (entidad piloto) | Crear vista `UNION ALL` de Silver QAD y `lh_silver_sap` para la entidad piloto. Probar con filtro por `company_code` y `source_system`. | Vista conformada funcionando; consultas de prueba documentadas | 2 |
| **2.3** | Validación punta a punta | Validar volúmenes y muestreo de registros SAP vs. QAD. Comprobar que un reporte Gold o vista RPA que use esa entidad funciona correctamente con datos unificados. Ajustes menores si aplica. | Documento de validación (OK + lecciones aprendidas) | 2 |
| **2.4** | Documentar patrón estándar replicable | Redactar guía paso a paso: tablas de control a actualizar, nombres de artefactos, estructura de notebook, cómo agregar una nueva entidad SAP. | Guía *"Cómo agregar una entidad SAP"* | 1 |

**Entregable de fase:** Patrón replicable + guía de implementación.

---

## Fase 3: Rollout entidades Empresas TECC — 5 semanas (27-Apr al 30-May-2026)

**Objetivo:** Implementar todas las entidades necesarias para que las vistas Gold (reportes y RPAs) de SEL, SCO y STU consuman datos SAP vía capa conformada, antes del go-live de SEL.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **3.1** | Definir orden de implementación | Confirmar el orden final de entidades considerando dependencias en vistas/RPAs. Maestros primero: `dim_customer`, `dim_material`, `dim_vendor`. Luego transaccionales: órdenes de venta, facturas, documentos de material. | Lista ordenada con dependencias y responsable por entidad | 2 |
| **3.2** | Implementar entidades (Bronze → Silver → Conformada) | Por cada entidad, aplicar el patrón del piloto: ampliar Bronze SAP si falta CDS, ETL → `lh_silver_sap`, crear vista conformada, registrar en control, prueba básica de volumen. | Todas las entidades críticas en `lh_silver_sap` y capa conformada | 30 |
| **3.3** | Revisión de calidad y estándares (continua) | Revisar por lotes: nombres snake_case, tipos, `source_system`, `company_code`, `record_id`. Aplicar y documentar estándares. Puede solaparse con 3.2. | Checklist de calidad completado por entidad | Continuo |
| **3.4** | Extender `source_system` en Silver QAD donde falte | Añadir `source_system = 'QAD'` en las tablas Silver que recibirán datos SAP y aún no tienen el campo, sin modificar la lógica de pipelines QAD. | Silver listo para multi-origen en todas las entidades del alcance | 2 |

**Entregable de fase:** Vistas conformadas y reportes/RPAs listos para el go-live de SEL.

---

## Fase 4: Go-live SEL — 1 semana (01-Jun al 07-Jun-2026)

**Objetivo:** Reportes Gold y vistas RPA de SEL operativos con datos SAP a través de la capa conformada; soporte activo post go-live.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **4.1** | Activar go-live SEL y validación rápida | Actualizar tabla/parámetros de go-live con la fecha real de SEL (activar `company_code = 'SEL'` como SAP-only en la capa conformada). Ejecutar validación rápida de vistas y reportes. | Tabla go-live actualizada; validación ejecutada el día del go-live | 1 |
| **4.2** | Validación con negocio | Validar con el área de negocio los reportes Gold y vistas RPA que consumen datos de SEL. Comparar con reportes estándar SAP si existen. Documentar diferencias o ajustes pendientes. | Acta de validación con negocio (OK o lista de ajustes priorizados) | 4 |
| **4.3** | Soporte post go-live SEL | Atender incidencias de datos, ajustes menores de mapeo y correcciones de filtros. Monitorizar volúmenes y latencia de pipelines. | Estabilización operativa de SEL (sin incidencias abiertas críticas) | 3 |

**Entregable de fase:** SEL en producción con datos SAP integrados.

---

## Fase 5: STU + SCO + Bloques financieras — ~3.5 semanas (08-Jun al 20-Jun-2026)

**Objetivo:** Go-live de STU + 2.º bloque de financieras (Mayo 2026) y de SCO + último bloque de financieras (Junio 2026); estabilización final del proceso.

| Código | Actividad | Descripción | Entregable | Días |
|--------|-----------|-------------|------------|------|
| **5.1** | Go-live STU + 2.º bloque financieras | Activar go-live para STU y las empresas del 2.º bloque financiero. Validación rápida por empresa de reportes Gold y RPAs. Soporte inicial. | STU y 2.º bloque financiero cubiertos en capa conformada | 7 |
| **5.2** | Go-live SCO + último bloque financieras | Activar go-live para SCO y las empresas del último bloque financiero. Validación rápida + validación ligera de financieras (impacto reducido en vistas). | Transición cerrada para todas las empresas TECC | 7 |
| **5.3** | Estabilización final | Revisión integral de pipelines activos, optimización (particiones, programación Full/Incremental, alertas), limpieza de artefactos temporales. Cierre de documentación operativa. | Proceso estable + documentación operativa completa | 7 |

**Entregable de fase:** Transición completa y proceso estabilizado.

---

## Resumen de tiempos

| Fase | Nombre | Duración | Inicio | Fin | Hito |
|------|--------|----------|--------|-----|------|
| 0 | Cierre estrategia | 1 sem | 17-Mar-2026 | 21-Mar-2026 | Priorización lista |
| 1 | Mapeo y diseño | 3 sem | 24-Mar-2026 | 11-Apr-2026 | Diseño y matriz listos |
| 2 | Piloto (1 entidad) | 1.5 sem | 14-Apr-2026 | 24-Apr-2026 | Patrón replicable |
| 3 | Rollout entidades TECC | 5 sem | 27-Apr-2026 | 30-May-2026 | Vistas listas para SEL |
| 4 | Go-live SEL | 1 sem | 01-Jun-2026 | 07-Jun-2026 | SEL en producción |
| 5 | STU + SCO + Financieras | 3.5 sem | 08-Jun-2026 | 20-Jun-2026 | Transición cerrada |
| **Total** | | **~14 sem** | **17-Mar-2026** | **20-Jun-2026** | |

---

## Nota sobre capacidad y riesgos

- **Capacidad:** Las estimaciones asumen ~40–50% del tiempo del equipo dedicado a SAP en paralelo a la operación habitual (Fabric, RPAs, Sistema de Indicadores). Si se libera más capacidad en periodos críticos (especialmente antes de go-live SEL), las fases pueden acortarse.
- **Riesgo principal:** La cadena secuencial Fase 0→3 deja el go-live SEL en **junio** con duraciones mínimas desde hoy. Si el objetivo es Abril, se requiere comprimir Fases 1-2 (solapamiento) y/o reducir el alcance del piloto.
- **Dependencia crítica:** la conectividad al Data Gateway (SAPHANADB) y la disponibilidad del equipo SAP para validar CDS afectan directamente Fase 1.

Para el detalle de equipo, riesgos completos y próximos pasos inmediatos, ver [`Plan_de_Accion_Integracion_SAP_Fabric.md`](Plan_de_Accion_Integracion_SAP_Fabric.md).
