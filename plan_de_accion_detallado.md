# Plan de acción detallado – Integración SAP en Fabric

Este documento es el cronograma detallado derivado de la presentación *Estrategia y plan de acción – Integración SAP en Fabric*. Explota cada fase de la vista de cronograma en **actividades concretas**, con **entregables claros** y **tiempo estimado** por actividad, para poder seguir y ejecutar el plan de integración SAP S/4 HANA en la arquitectura medallion (Estrategia 3: Silver dual + capa conformada).

**Referencia:** [Presentacion_Estrategia_Plan_SAP_Fabric.html](Presentacion_Estrategia_Plan_SAP_Fabric.html) (sección Vista de cronograma). [Plan_de_Accion_Integracion_SAP_Fabric.md](Plan_de_Accion_Integracion_SAP_Fabric.md) y [Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md](Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md) para contexto completo.

---

## Vista de cronograma (resumen)

| Fase | Contenido | Duración | Hito |
|------|-----------|----------|------|
| 0 | Cierre estrategia, lista entidades | 1–2 sem | Priorización lista |
| 1 | Mapeo, diseño lh_silver_sap y conformada | 2–3 sem | Diseño y matriz listos |
| 2 | Piloto una entidad | 1–2 sem | Patrón replicable |
| 3 | Rollout entidades Empresas TECC | 5–7 sem | Vistas (reportes y RPA's) listas para SEL |
| 4 | Go-live SEL (Abril 2026) | 1–2 sem | SEL en producción con SAP |
| 5 | STU + 2.º bloque fin. (May), SCO + último bloque fin. (Jun) + estabilización | 3–4 sem | Transición cerrada |

**Total estimado:** 13–20 semanas.

---

## Fase 0: Cierre estrategia — Duración total: 1–2 semanas

**Objetivo:** Estrategia adoptada, lista de entidades que alimentan vistas (reportes y RPA's) para las Empresas TECC, y plan de extensión de `source_system` en Silver.

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **0.1** | Formalizar adopción Estrategia 3 y validar plan | Revisar y validar con stakeholders la adopción de Estrategia 3 (Silver dual + capa conformada) y el plan de acción; incorporar ajustes si aplica. | OK o ajustes al plan documentados | 2–3 días |
| **0.2** | Definir y documentar lista de entidades Silver | Identificar las entidades Silver que alimentan las vistas Gold (reportes y RPA's) para las Empresas TECC (SEL, SCO, STU). Priorizar orden: maestros primero, luego transaccionales. | Lista priorizada de entidades (ej. clientes, materiales, órdenes venta, facturas) | 3–4 días |
| **0.3** | Identificar tablas con/sin source_system y plan de extensión | Revisar qué tablas Silver ya tienen el campo `source_system` y cuáles no; definir plan para extenderlo donde haga falta sin romper pipelines QAD. | Lista de tablas y plan de cambio (faseado si aplica) | 1–2 días |

**Entregable de fase:** Priorización lista (lista de entidades + plan `source_system`).

---

## Fase 1: Mapeo y diseño — Duración total: 2–3 semanas

**Objetivo:** Matriz de mapeo SAP → Silver por entidad, criterio Full/Incremental por CDS, diseño explícito de lh_silver_sap y de la capa conformada; Bronze SAP ampliado para el piloto.

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **1.1** | Matriz de mapeo por entidad (CDS ↔ Silver) | Por cada entidad priorizada, identificar la CDS (o tablas) SAP equivalente usando SE11/HANA Studio (SQL view name para conector). Documentar mapeo campo a campo (Silver ↔ SAP), tipos, nulos y reglas. | Matriz de mapeo por entidad | 1–1,5 sem |
| **1.2** | Full vs Incremental y registro en control SAP | Por cada CDS: revisar si expone campo de última modificación o anotación delta; definir Full o Incremental. Registrar en `source_to_bronze_control_sap` (load_type, watermark_column si aplica). | Control SAP actualizado; documentación breve por objeto | 3–4 días |
| **1.3** | Diseño lh_silver_sap | Definir diseño de lh_silver_sap: mismo contrato que Silver actual (nombres y estructura tipo QAD) por entidad; lista de tablas y columnas; `source_system = 'SAP'`, `company_code` desde MANDT o equivalente. | Documento de diseño lh_silver_sap (tablas/columnas por entidad) | 2–3 días |
| **1.4** | Diseño capa conformada | Definir vistas UNION por entidad (lh_silver_qad + lh_silver_sap), nombres, uso de go-live por company_code si aplica; indicar si alguna entidad requiere tabla materializada en lugar de vista. | Especificación de la capa conformada (vistas vs tablas; nombres) | 2 días |
| **1.5** | Ampliar lh_bronze_sap con CDS del piloto | Incluir en lh_bronze_sap las CDS necesarias para la entidad piloto (Fase 2); registrar en `source_to_bronze_control_sap`. | Pipelines/artefactos Source → Bronze SAP para piloto; control actualizado | 2–3 días |

**Entregable de fase:** Diseño y matriz listos.

---

## Fase 2: Piloto — Duración total: 1–2 semanas

**Objetivo:** Una entidad de punta a punta: Bronze SAP → lh_silver_sap → capa conformada → validación; patrón documentado para replicar en siguientes entidades.

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **2.1** | ETL Bronze SAP → lh_silver_sap (entidad piloto) | Implementar ETL para la entidad piloto (notebook o pipeline parametrizado): mapeo según matriz, `source_system`, `company_code`. Registrar en `bronze_to_silver_control_sap`. | Pipeline/notebook; tabla en lh_silver_sap | 3–4 días |
| **2.2** | Vista conformada para la entidad piloto | Crear vista conformada (UNION de Silver QAD y lh_silver_sap para esa entidad). Probar consulta con filtro por company_code y source_system. | Vista conformada probada | 1–2 días |
| **2.3** | Validación punta a punta | Validar volúmenes y muestreo de registros SAP vs QAD; comprobar que un reporte Gold o vista RPA que use esa entidad funciona con datos unificados. Ajustes menores si hace falta. | OK de validación; documento de lecciones aprendidas | 2–3 días |
| **2.4** | Documentar patrón estándar | Documentar pasos, nombres y uso de tablas de control para replicar el flujo en siguientes entidades. | Guía "cómo agregar una entidad SAP" | 1 día |

**Entregable de fase:** Patrón replicable.

---

## Fase 3: Rollout entidades Empresas TECC — Duración total: 5–7 semanas

**Objetivo:** Todas las entidades necesarias para que las vistas Gold (reportes y RPA's) de las Empresas TECC consuman datos SAP vía capa conformada antes del go-live de SEL.

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **3.1** | Priorizar orden de entidades | Definir orden de implementación: maestros primero (clientes, materiales, proveedores), luego transaccionales; considerar dependencias y uso en vistas/RPA. | Orden de implementación documentado | 2–3 días |
| **3.2** | Implementar entidades (Bronze, ETL, vista conformada, control, prueba) | Por cada entidad: ampliar Bronze SAP si falta CDS; ETL → lh_silver_sap; vista conformada; registro en control; prueba básica. Reutilizar patrón del piloto. | Todas las entidades críticas en lh_silver_sap y capa conformada | 4–6 sem |
| **3.3** | Revisión de calidad y estándares | Revisar por lote: nombres, tipos, `source_system`, `company_code`; aplicar estándares definidos. | Ajustes y estándares documentados | Continuo |
| **3.4** | Extender source_system en tablas Silver | Añadir o completar el campo `source_system` en las tablas Silver que recibirán datos SAP y aún no lo tengan, sin modificar la lógica QAD. | Silver listo para multi-origen donde aplique | 1–2 días (repartidos) |

**Entregable de fase:** Vistas (reportes y RPA's) listas para SEL.

---

## Fase 4: Go-live SEL — Duración total: 1–2 semanas

**Objetivo:** Validar que las vistas (reportes y RPA's) que usan datos de SEL funcionan con datos SAP vía capa conformada; soporte post go-live (Abril 2026).

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **4.1** | Actualizar go-live y validación rápida | Actualizar tabla o parámetros de go-live con la fecha real de SEL. Ejecutar validación rápida de vistas conformadas y reportes que consumen datos de SEL. | Tabla go-live actualizada; validación rápida ejecutada | 0,5–1 día |
| **4.2** | Validación con negocio | Validar con negocio reportes Gold y vistas RPA que consumen datos de SEL; comparar con reportes estándar SAP si existe. | OK de negocio o lista de ajustes | 3–5 días |
| **4.3** | Soporte post go-live | Atender incidencias de datos y ajustes menores de mapeo o filtros tras el go-live de SEL. | Estabilización operativa | Resto de la fase |

**Entregable de fase:** SEL en producción con SAP.

---

## Fase 5: STU, SCO y bloques financieras — Duración total: 3–4 semanas

**Objetivo:** Go-live de STU + 2.º bloque de financieras (Mayo 2026) y de SCO + último bloque de financieras (Junio 2026); estabilización final del proceso.

### Actividades

| Código | Actividad | Descripción | Entregables | Tiempo |
|--------|-----------|-------------|-------------|--------|
| **5.1** | Go-live STU + 2.º bloque financieras (Mayo) | Actualizar go-live con fechas reales. Validación rápida por empresa de reportes Gold/RPA; soporte inicial. | Empresas del bloque cubiertas en capa conformada | 1–1,5 sem |
| **5.2** | Go-live SCO + último bloque financieras (Junio) | Actualizar go-live. Validación rápida; validación ligera para financieras (impacto reducido en vistas). | Transición cerrada para todas las empresas | 1–1,5 sem |
| **5.3** | Estabilización final | Revisión de pipelines, optimización (particiones, programación Full/Incremental), documentación operativa. | Proceso estable; documentación de operación | 1 sem |

**Entregable de fase:** Transición cerrada.

---

## Resumen de tiempos

| Fase | Nombre | Duración | Hito |
|------|--------|----------|------|
| 0 | Cierre estrategia | 1–2 sem | Priorización lista |
| 1 | Mapeo y diseño | 2–3 sem | Diseño y matriz listos |
| 2 | Piloto | 1–2 sem | Patrón replicable |
| 3 | Rollout entidades Empresas TECC | 5–7 sem | Vistas listas para SEL |
| 4 | Go-live SEL | 1–2 sem | SEL en producción con SAP |
| 5 | STU, SCO y bloques financieras | 3–4 sem | Transición cerrada |
| **Total** | | **13–20 sem** | |

---

## Nota sobre capacidad

Las estimaciones asumen que el trabajo de integración SAP se ejecuta en **paralelo** a la operación habitual (Fabric, RPA's, Sistema de Indicadores). En conjunto, se considera que aproximadamente **40–50%** del tiempo del equipo se dedica a SAP; el resto a BAU. Si se reserva más capacidad para SAP en periodos críticos (por ejemplo, antes del go-live de SEL), las fases pueden acortarse. Para el detalle de equipo, riesgos y próximos pasos, consultar [Plan_de_Accion_Integracion_SAP_Fabric.md](Plan_de_Accion_Integracion_SAP_Fabric.md).
