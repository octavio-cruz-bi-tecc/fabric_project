# Plan de acción: integración SAP en arquitectura Medallion (Fabric)

Este plan detalla los pasos siguientes y estimaciones de tiempo para incorporar SAP S/4 HANA a la arquitectura medallion existente (Estrategia 3: Silver dual + capa conformada), considerando el equipo actual, la incorporación de un nuevo Data Engineer y las actividades en paralelo (BAU).

**Documento de referencia:** [Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md](./Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md)

---

## 1. Contexto del equipo y capacidad

### 1.1 Equipo

| Rol | Cantidad | Responsabilidad principal en SAP |
|-----|----------|-----------------------------------|
| **Data Architect** | 1 | Diseño, mapeos, estándares, revisión de controles y capa conformada. |
| **Data Engineer** | 1 (actual) | Pipelines, notebooks, ETL Bronze→Silver SAP, mantenimiento artefactos. |
| **Data Engineer** | 1 (próxima contratación) | Refuerzo en ETL, pipelines y soporte; puede asumir piloto o entidades una vez incorporado. |

**Total:** 2 personas hoy; 3 en cuanto se incorpore el nuevo Data Engineer.

### 1.2 Actividades en paralelo (BAU)

El equipo además realiza:

- **Mantenimiento de la arquitectura medallion en Fabric** (Bronze QAD, Silver, Gold).
- **Migración de vistas para RPA** (cálculo automático de resultados de indicadores/KPI) de Oracle a Fabric.
- **Soporte a vistas Gold** que consumen los reportes.
- **Soporte a vistas RPA** ya migradas o en uso.
- **Mejora continua** de pipelines, notebooks y artefactos de ETL en Fabric.

**Implicación:** El trabajo de integración SAP se ejecuta en **paralelo** al BAU. Las estimaciones de este plan asumen que una parte del tiempo del equipo (aprox. **40–50%** en conjunto) se dedica a SAP; el resto a BAU y otras prioridades. Si se puede reservar más capacidad para SAP en periodos críticos (ej. antes del go-live de SEL), los plazos se acortan.

---

## 2. Supuestos y dependencias

- **Orden de go-live:** (1) 1.er bloque de financieras Febrero 2026 (ya en operación); (2) **SEL** Abril 2026; (3) **STU + 2.º bloque de financieras** Mayo 2026; (4) **SCO + último bloque de financieras** Junio 2026.
- **Situación actual (marzo 2026):** SEL sale en 1 mes (abril 2026); priorizar tener piloto y entidades críticas listas para SEL.
- **Estrategia adoptada:** Estrategia 3 (Silver dual + capa conformada); ver documento de estrategia.
- **Ya disponible:** lh_bronze_sap, extracción piloto de CDS, conectores SAP, Data Gateway, tablas de control (source_to_bronze_control_sap, bronze_to_silver_control_sap).

---

## 3. Fases, pasos y estimaciones

### Fase 0: Cierre de estrategia y preparación inicial (2–3 semanas)

*Objetivo:* Dejar adoptada la estrategia, el contrato Silver y los criterios de priorización para no bloquear el diseño ni el piloto.

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 0.1 | Formalizar adopción de Estrategia 3 y revisar este plan con stakeholders. | Data Architect | 2–3 días | OK/ajustes al plan. |
| 0.2 | Definir y documentar **lista de entidades Silver** que alimentan Gold/datamarts para las 3 manufactureras (SEL, SCO, STU); priorizar orden (maestros primero). | Data Architect + Data Engineer | 3–5 días | Lista priorizada de entidades (ej. clientes, materiales, órdenes venta, facturas, etc.). |
| 0.3 | Crear **tabla de control go-live** (company_code, sap_go_live_date) en lh_control_erp o Gold y poblarla con fechas: 1.er bloque financieras Feb 2026, SEL Abr 2026, STU + 2.º bloque financieras May 2026, SCO + último bloque financieras Jun 2026. | Data Engineer | 1 día | Tabla disponible para capa conformada y reportes. |
| 0.4 | Identificar tablas Silver que ya tienen `source_system` y las que faltan; plan para extender `source_system` donde haga falta (sin romper pipelines QAD). | Data Architect | 1–2 días | Lista de tablas y plan de cambio (faseado si hace falta). |

**Duración total fase 0:** 2–3 semanas (en paralelo con BAU).  
**Capacidad asumida:** ~40–50% del tiempo del equipo en estas tareas.

---

### Fase 1: Análisis de mapeo y diseño (4–5 semanas)

*Objetivo:* Matriz de mapeo SAP → Silver (estilo QAD), lista de CDS por entidad, criterio Full/Incremental por objeto y diseño explícito de lh_silver_sap y capa conformada.

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 1.1 | Por cada entidad priorizada: identificar CDS (o tablas) SAP equivalentes (SE11, HANA Studio, SQL view name para conector). Documentar en **matriz de mapeo** (campo Silver ↔ campo SAP; tipos, nulos, reglas). | Data Architect (diseño) + Data Engineer (consulta técnica) | 2–3 semanas | Matriz de mapeo por entidad (al menos para las 5–8 entidades más críticas para manufactureras). |
| 1.2 | Para cada CDS/origen SAP: revisar si tiene campo de última modificación o anotación delta (SE11 / doc SAP); definir **Full vs Incremental** y registrar en **source_to_bronze_control_sap** (load_type, watermark_column si aplica). | Data Engineer | 3–5 días | Control SAP actualizado; doc breve por objeto. |
| 1.3 | Diseño explícito de **lh_silver_sap**: mismo contrato que Silver actual (nombres + estructura tipo QAD) por entidad; lista de tablas y columnas; `source_system = 'SAP'`, `company_code` desde MANDT o equivalente. | Data Architect | 3–5 días | Documento de diseño lh_silver_sap (tablas/columnas por entidad). |
| 1.4 | Diseño de **capa conformada**: vistas UNION ALL por entidad (lh_silver_qad + lh_silver_sap), uso de tabla go-live por company_code para reportes “actuales”. Definir si alguna entidad requiere tabla materializada en lugar de vista. | Data Architect | 2–3 días | Especificación capa conformada (vistas vs tablas; nombres). |
| 1.5 | Ampliar **lh_bronze_sap** con las CDS necesarias para el piloto (Fase 2) y registrar en **source_to_bronze_control_sap**. | Data Engineer | 2–4 días | Pipelines/artefactos Source → Bronze SAP para entidad piloto; control actualizado. |

**Duración total fase 1:** 4–5 semanas.  
**Dependencias:** Fase 0 cerrada (lista de entidades y prioridad).  
**Nota:** Parte de 1.1 puede avanzar en paralelo con 1.2–1.4 una vez definidas las primeras entidades.

---

### Fase 2: Piloto (una entidad de punta a punta) (2–3 semanas)

*Objetivo:* Una entidad (recomendación: clientes o materiales) con flujo completo SAP → Bronze → lh_silver_sap → capa conformada; validación y patrón replicable.

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 2.1 | Implementar ETL **Bronze SAP → lh_silver_sap** para la entidad piloto (notebook o pipeline parametrizado); mapeo según matriz; `source_system`, `company_code`. Registrar en **bronze_to_silver_control_sap**. | Data Engineer | 3–5 días | Pipeline/notebook; tabla en lh_silver_sap. |
| 2.2 | Crear **vista conformada** (UNION de Silver QAD y lh_silver_sap para esa entidad) en el lakehouse que consume Gold. Probar consulta con filtro por company_code y source_system. | Data Engineer | 1–2 días | Vista conformada; prueba de lectura desde Gold o reporte. |
| 2.3 | Validación: volúmenes, muestreo de registros SAP vs QAD; comprobar que un reporte Gold (o vista RPA) que use esa entidad sigue funcionando con datos unificados. Ajustes menores si hace falta. | Data Architect + Data Engineer | 2–3 días | OK de validación; doc de lecciones aprendidas. |
| 2.4 | Documentar **patrón estándar** (pasos, nombres, control tables) para replicar en siguientes entidades. | Data Architect | 1 día | Guía corta “cómo agregar una entidad SAP”. |

**Duración total fase 2:** 2–3 semanas.  
**Dependencias:** Fase 1 completada (mapeo y diseño de la entidad piloto; Bronze SAP con datos de esa entidad).

---

### Fase 3: Rollout entidades para manufactureras (8–12 semanas)

*Objetivo:* Todas las entidades necesarias para que Gold/datamarts y vistas RPA que impactan a SEL, SCO y STU consuman datos de SAP vía capa conformada antes del go-live de SEL (Abril 2026).

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 3.1 | Priorizar orden de entidades (maestros primero: clientes, materiales, proveedores; luego transaccionales: órdenes venta, facturas, etc.) según dependencias y uso en Gold/RPA. | Data Architect | 2–3 días | Orden de implementación. |
| 3.2 | Por cada entidad: (1) Ampliar Bronze SAP si falta CDS; (2) ETL Bronze SAP → lh_silver_sap; (3) Vista conformada; (4) Registrar en control; (5) Prueba básica. Reutilizar patrón del piloto. | Data Engineer(s) | 6–10 semanas | Todas las entidades críticas para manufactureras en lh_silver_sap y capa conformada. |
| 3.3 | Revisión de calidad y estándares (nombres, tipos, source_system, company_code) en cada lote de entidades. | Data Architect | Continuo (revisión por lote) | Ajustes y estándares documentados. |
| 3.4 | Extender `source_system` a las tablas Silver que aún no lo tengan y que recibirán datos SAP (sin modificar lógica QAD). | Data Engineer | 1–2 días (puede repartirse) | Silver listo para multi-origen donde aplique. |

**Duración total fase 3:** 8–12 semanas (depende del número de entidades y de la capacidad dedicada; con 2 personas a ~50% puede alargarse; con 3 y priorización clara puede acortarse).  
**Dependencias:** Fase 2 cerrada; incorporación del segundo Data Engineer acelera si se asigna a entidades en paralelo.

---

### Fase 4: Go-live SEL (Abril 2026) y soporte (2–3 semanas alrededor del go-live)

*Objetivo:* Validar que los reportes Gold y vistas RPA que usan datos de SEL funcionan con datos SAP vía capa conformada; soporte post go-live.

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 4.1 | Actualizar tabla **go-live** con fecha real de SEL. Verificar que las vistas conformadas y reportes filtran correctamente por company_code y/o go-live. | Data Engineer | 0,5–1 día | Tabla go-live actualizada; smoke test. |
| 4.2 | Validación con negocio: reportes Gold y vistas RPA que consumen datos de SEL; comparar con reportes estándar SAP si existe. | Data Architect + Data Engineer | 3–5 días | OK de negocio o lista de ajustes. |
| 4.3 | Soporte post go-live: incidencias de datos, ajustes menores de mapeo o filtros. | Equipo | 1–2 semanas | Estabilización. |

**Duración total fase 4:** 2–3 semanas (centradas en el go-live de SEL).  
**Dependencias:** Fase 3 avanzada o cerrada para las entidades que usa SEL.

---

### Fase 5: STU, SCO y bloques de financieras (Mayo y Junio 2026)

*Objetivo:* Ajustes y validación para STU (Mayo) y SCO (Junio); validación ligera para 2.º y 3.er bloque de financieras (mismo mes que STU y SCO respectivamente).

| # | Actividad | Responsable | Duración | Entregable / nota |
|---|------------|-------------|----------|--------------------|
| 5.1 | Go-live **STU + 2.º bloque financieras** (Mayo 2026): actualizar tabla go-live; smoke test de reportes Gold/RPA por empresa; soporte corto. | Data Engineer | 1–2 semanas | STU y 2.º bloque financieras cubiertos. |
| 5.2 | Go-live **SCO + último bloque financieras** (Junio 2026): actualizar go-live; smoke test; validación ligera para financieras (poco impacto en datamarts/vistas). | Data Engineer | 1–2 semanas | SCO y último bloque financieras en capa conformada. |
| 5.3 | Estabilización final: revisión de pipelines, optimización (particiones, programación Full/Incremental), documentación operativa. | Equipo | 1–2 semanas | Proceso estable; doc de operación. |

**Duración total fase 5:** 4–6 semanas (en calendario, repartidas según fechas de go-live).  
**Dependencias:** Fase 4 cerrada para SEL; fechas de go-live STU+financieras (Mayo) y SCO+financieras (Junio).

---

## 4. Vista de cronograma (elapsed time)

Las duraciones son **semanas de calendario** asumiendo dedicación parcial (~40–50% del equipo a SAP). Si se aumenta la dedicación en periodos clave, las fases se acortan.

| Fase | Contenido | Duración aprox. | Hito |
|------|-----------|------------------|------|
| **0** | Cierre estrategia, lista entidades, tabla go-live, plan source_system | 2–3 sem | Estrategia y priorización listas |
| **1** | Mapeo SAP→Silver, diseño lh_silver_sap y capa conformada, control Full/Delta | 4–5 sem | Diseño y matriz listos |
| **2** | Piloto una entidad (Bronze→Silver SAP→conformada→validación) | 2–3 sem | Patrón replicable |
| **3** | Rollout entidades para manufactureras (SEL, SCO, STU) | 8–12 sem | Gold/RPA listos para SEL |
| **4** | Go-live SEL (Abril 2026) + validación y soporte | 2–3 sem | SEL en producción con SAP |
| **5** | Go-live STU + 2.º bloque financieras (May), SCO + último bloque financieras (Jun) + estabilización | 4–6 sem | Transición cerrada |

**Tiempo total estimado desde inicio de Fase 0 hasta cierre de Fase 5:** aprox. **22–32 semanas** (5,5–8 meses) en calendario, alineado con una transición de 4–6 meses de uso dual de sistemas más tiempo de preparación previa.

**Punto crítico:** Estamos en **marzo 2026**; SEL sale en **1 mes** (abril 2026). La Fase 3 (rollout de entidades) debe estar lo más avanzada posible antes del go-live de SEL. Priorizar piloto y entidades críticas para SEL.

---

## 5. Asignación sugerida por rol

| Rol | Fases donde lleva el peso | Actividades típicas |
|-----|----------------------------|----------------------|
| **Data Architect** | 0, 1, 2 (validación), 3 (revisión), 4 (validación) | Estrategia, mapeos, diseño lh_silver_sap y capa conformada, estándares, validación con negocio. |
| **Data Engineer (actual)** | 1 (técnico), 2, 3, 4, 5 | Pipelines, notebooks, ETL Bronze→Silver SAP, vistas conformadas, control tables, soporte. |
| **Data Engineer (nuevo)** | 3, 4, 5 (cuando se incorpore) | Réplica de entidades siguiendo el patrón del piloto; pipelines; soporte. |

La incorporación del segundo Data Engineer permite repartir entidades en Fase 3 y acortar el rollout (por ejemplo, de 12 a ~8 semanas si hay buen paralelismo).

---

## 6. Riesgos y mitigación

| Riesgo | Mitigación |
|--------|------------|
| BAU (RPA, Gold, pipelines) consume más tiempo del previsto | Reservar bloques fijos en la semana para SAP (ej. 2 días por persona); priorizar entidades mínimas para SEL. |
| Retraso en contratación del segundo Data Engineer | Fase 3 más larga; concentrar en las entidades imprescindibles para go-live SEL. |
| CDS SAP sin delta o con estructura distinta a la esperada | Usar Full para esas entidades (sección 6 del doc de estrategia); documentar en control; revisar con SAP si hace falta Custom CDS. |
| Cambios en fechas de go-live (SEL, SCO, STU, financieras) | Mantener tabla go-live como única fuente de verdad; ajustar solo fechas sin cambiar diseño. |

---

## 7. Próximos pasos inmediatos

1. **Validar este plan** con el responsable de área y, si aplica, con el proyecto SAP (fechas de go-live y alcance).
2. **Cerrar Fase 0** (2–3 semanas): adopción de Estrategia 3, lista de entidades prioritarias, tabla go-live, plan de `source_system`.
3. **Iniciar Fase 1** en paralelo: asignar responsable de la matriz de mapeo (Data Architect) y de revisión de CDS/control (Data Engineer).
4. **Priorizar** piloto (Fase 2) y entidades para SEL; con SEL en 1 mes (abril 2026), revisar capacidad del equipo para tener lo mínimo listo a tiempo.

---

*Documento generado a partir del contexto del equipo, la estrategia de integración SAP (Estrategia 3) y el cronograma de go-live: 1.er bloque financieras Feb 2026, SEL Abr 2026, STU + 2.º bloque financieras May 2026, SCO + último bloque financieras Jun 2026. Situación actual: marzo 2026, SEL en 1 mes. Actualizar según cambios de fechas o de capacidad.*
