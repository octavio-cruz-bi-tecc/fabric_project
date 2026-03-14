# Borrador de correo – Avance semanal

*Documento base para redactar el correo de avance de la semana. Incluye detalle por área para copiar, adaptar o resumir según el destinatario.*

---

## 1. Investigación, análisis y determinación de la estrategia para la incorporación de SAP a la estructura de Fabric

**Resumen para el correo:**

Se completó la investigación, el análisis y la definición de la estrategia para incorporar **SAP S/4 HANA Cloud Private Edition** en la arquitectura medallion existente en Microsoft Fabric (Bronze → Silver → Gold), que actualmente consume **QAD MFG**, de modo que los datamarts y vistas Gold sirvan datos de ambos ERPs de forma unificada y transparente para el usuario final.

**Detalle técnico y de decisión (para incluir o resumir):**

- **Contexto analizado:** Se revisó la arquitectura actual (lh_bronze_qad1, lh_bronze_qad2, lh_bronze_sap), la capa Silver (lh_silver_erp con estructura genérica y convenciones company_code / source_system), las tablas de control (source_to_bronze_control, source_to_bronze_control_sap, bronze_to_silver_control, bronze_to_silver_control_sap, silver_to_gold_control) y el cronograma de go-live por empresa (1.er bloque financieras Feb 2026; SEL Abr 2026; STU + 2.º bloque financieras May 2026; SCO + último bloque financieras Jun 2026).
- **Estrategias evaluadas:** Se evaluaron tres opciones: (1) Silver unificado (una sola Silver para QAD + SAP), (2) Silver dual sin capa conformada (Gold hace UNION/JOIN de ambos Silvers), (3) Silver dual + capa conformada (dos Silvers técnicos y una capa que unifica para que Gold siga consumiendo de un solo punto).
- **Decisión adoptada:** Se adoptó la **Estrategia 3 (Silver dual + capa conformada)**. Se mantiene el Silver QAD intacto; se construye **lh_silver_sap** con la misma estructura genérica (contrato único: company_code, snake_case, mismos nombres de tabla y columnas que Silver actual). Se añade una capa de conformación (vistas UNION ALL de tablas homólogas de lh_silver_qad y lh_silver_sap, o ETL ligero de merge) de modo que Gold siga leyendo solo de esa capa, sin conocer la fuente. Esto minimiza el riesgo sobre los flujos QAD en producción y mantiene transparencia para reportes y RPAs.
- **Documentación generada:** Estrategia ampliada (Estrategia_Migracion_QAD_SAP_Medallion_Ampliada.md), plan de acción por fases (Plan_de_Accion_Integracion_SAP_Fabric.md) y presentación para stakeholders (Presentacion_Estrategia_Plan_SAP_Fabric.html). Incluyen: uso de CDS views para Bronze SAP, criterios Full/Incremental por objeto, tabla de control go-live por company_code, y próximos pasos (Fase 0: cierre de estrategia y lista de entidades; Fase 1: mapeo y diseño; Fase 2: piloto una entidad; Fase 3: rollout entidades para manufactureras; Fases 4 y 5: go-live SEL, STU, SCO y financieras).

**Frase sugerida para el correo (corta):**  
*Se concluyó la investigación y el análisis para la incorporación de SAP a la arquitectura Fabric. Se definió y documentó la Estrategia 3 (Silver dual + capa conformada), con plan de acción por fases y presentación para stakeholders, manteniendo el Silver QAD intacto y preparando lh_silver_sap y la capa conformada para unificar datos de ambos ERPs en Gold.*

---

## 2. Entrevistas y seguimiento para contratar al 3.er integrante del equipo

**Resumen para el correo:**

Se realizaron entrevistas y se dio seguimiento al proceso de contratación del **tercer integrante del equipo** (segundo Data Engineer), necesario para reforzar capacidad en pipelines, ETL Bronze → Silver SAP, mantenimiento de artefactos y soporte, y para acelerar el rollout de entidades hacia el go-live de SEL (Abril 2026).

**Detalle (para incluir o resumir):**

- El equipo actual está formado por 1 Data Architect y 1 Data Engineer. La incorporación del segundo Data Engineer permitirá repartir entidades en la Fase 3 del plan SAP y acortar el tiempo de rollout (por ejemplo, de 12 a ~8 semanas con buen paralelismo).
- Las actividades de esta semana incluyeron: [ *completar según lo realizado: número de entrevistas, etapas (técnica, con negocio, etc.), candidatos en proceso, próximos pasos con RRHH o contratación.* ]

**Frase sugerida para el correo (corta):**  
*Se llevaron a cabo entrevistas y seguimiento al proceso de contratación del tercer integrante del equipo (Data Engineer). [Indicar brevemente estado: número de candidatos en proceso, siguiente etapa, fecha estimada de incorporación si aplica.]*

---

## 3. Soporte para corrección de la conciliación de inventarios de SEL

**Resumen para el correo:**

Se brindó **soporte para la corrección de la conciliación de inventarios de SEL**, atendiendo incidencias, ajustes de reglas o fuentes de datos y validaciones necesarias para que los resultados de conciliación sean correctos y alineados con las expectativas de negocio.

**Detalle (para incluir o resumir):**

- [ *Describir de forma concreta lo realizado esta semana, por ejemplo:* ]
  - Revisión y corrección de lógica o fuentes utilizadas en el proceso de conciliación de inventarios para SEL.
  - Ajustes en pipelines, vistas o tablas Gold/Silver que alimentan los reportes de conciliación.
  - Validación de datos con negocio o con el equipo de SEL.
  - Documentación de cambios o criterios aplicados para futuras referencias.
- Considerando que **SEL tiene go-live en SAP en Abril 2026**, tener la conciliación de inventarios estable y correcta en Fabric es prioritario para la transición.

**Frase sugerida para el correo (corta):**  
*Se dio soporte para la corrección de la conciliación de inventarios de SEL, incluyendo [revisión de lógica / ajustes en pipelines o vistas / validación con negocio]. [Indicar si quedó cerrado o si hay pendientes para la siguiente semana.]*

---

## 4. Mantenimiento de la estructura medallion en Fabric

**Resumen para el correo:**

Se realizó **mantenimiento de la arquitectura medallion en Fabric**, asegurando la operación correcta de las capas Bronze (QAD y SAP), Silver y Gold, así como de los artefactos de ETL, tablas de control y convenciones establecidas.

**Detalle (para incluir o resumir):**

- **Bronze:** Mantenimiento de lh_bronze_qad1, lh_bronze_qad2 y lh_bronze_sap; revisión de pipelines Source → Bronze y de las tablas de control (source_to_bronze_control, source_to_bronze_control_sap). [ *Si hubo incidencias: detallar brevemente (ej. reprocesos, ajustes de programación, ampliación de CDS en Bronze SAP).* ]
- **Silver:** Operación y mejora continua de los pipelines Bronze QAD → Silver (bronze_to_silver_control); revisión de estándares (nombres, company_code, source_system) y de tablas en lh_silver_erp. [ *Si se trabajó en preparación para SAP: mencionar revisión de lista de entidades, extensión de source_system o diseño de lh_silver_sap.* ]
- **Gold:** Soporte a vistas y datamarts Gold que consumen los reportes; verificación de que los reportes siguen recibiendo datos correctos desde Silver. [ *Indicar si hubo cambios en vistas Gold, nuevas publicaciones o correcciones.* ]
- **Mejora continua:** Ajustes en notebooks, pipelines y documentación operativa; optimización de particiones, Z-ordering o programación (Full/Incremental) donde aplicó.

**Frase sugerida para el correo (corta):**  
*Se realizó mantenimiento de la estructura medallion en Fabric (Bronze QAD/SAP, Silver, Gold), incluyendo [operación de pipelines, revisión de controles, soporte a vistas Gold y mejoras en artefactos ETL].*

---

## 5. Migración y soporte de RPAs

**Resumen para el correo:**

Se avanzó en la **migración de vistas para RPA** (cálculo automático de resultados de indicadores/KPI) desde Oracle a Fabric, y se dio **soporte a las vistas RPA** ya migradas o en uso, garantizando que los procesos automatizados dispongan de datos correctos y estables.

**Detalle (para incluir o resumir):**

- **Migración:** [ *Indicar qué vistas o procesos RPA se migraron esta semana; qué entidades o indicadores cubren; estado de pruebas y validación.* ] Las vistas RPA en Fabric deben consumir desde Gold (o desde la capa conformada una vez integrado SAP) para que los indicadores sigan siendo transparentes al origen de datos (QAD hoy; QAD + SAP después del go-live).
- **Soporte:** [ *Indicar incidencias resueltas, ajustes de definición o rendimiento, o coordinación con el equipo de RPA.* ]
- En el plan de integración SAP, las vistas RPA que impactan a las manufactureras (SEL, SCO, STU) quedarán alimentadas por la capa conformada; el trabajo de esta semana en migración y soporte RPA contribuye a tener una base estable para la transición.

**Frase sugerida para el correo (corta):**  
*Se continuó con la migración de vistas para RPA de Oracle a Fabric [indicar cuáles o cuántas si aplica] y se brindó soporte a las vistas RPA ya en uso [indicar incidencias resueltas o mejoras realizadas].*

---

## 7. Soporte y mantenimiento al sistema de indicadores

**Resumen para el correo:**

Se brindó **soporte y mantenimiento al sistema de indicadores**, asegurando que las definiciones, las fuentes de datos (vistas Gold, datamarts) y la publicación de resultados estén actualizadas y alineadas con negocio.

**Detalle (para incluir o resumir):**

- [ *Describir de forma concreta:* ]
  - Actualización o corrección de indicadores (fórmulas, umbrales, periodos).
  - Revisión de las vistas Gold o tablas que alimentan el sistema de indicadores.
  - Resolución de incidencias (datos faltantes, desfases, errores de cálculo).
  - Coordinación con áreas de negocio para validación o nuevos requerimientos.
- El sistema de indicadores consume de la capa Gold (y en su caso de vistas RPA migradas); su estabilidad es crítica para reportes y para la automatización vía RPA.

**Frase sugerida para el correo (corta):**  
*Se realizó soporte y mantenimiento al sistema de indicadores, incluyendo [actualización de definiciones, revisión de fuentes de datos, resolución de incidencias y/o validación con negocio].*

---

## Resumen ejecutivo (opcional – una línea por punto)

*Versión ultra resumida para abrir o cerrar el correo.*

1. **SAP en Fabric:** Estrategia definida (Estrategia 3: Silver dual + capa conformada); documentación y plan de acción por fases listos.
2. **Contratación:** Entrevistas y seguimiento para el 3.er integrante del equipo (Data Engineer).
3. **SEL – Inventarios:** Soporte para corrección de la conciliación de inventarios de SEL.
4. **Medallion:** Mantenimiento de la estructura Bronze/Silver/Gold en Fabric.
5. **RPAs:** Migración y soporte de vistas RPA (Oracle → Fabric).
7. **Indicadores:** Soporte y mantenimiento al sistema de indicadores.

---

## Notas para redactar el correo

- **Destinatarios:** Ajustar el nivel de detalle (más técnico para el equipo de datos/arquitectura; más resumido para gerencia o proyecto SAP).
- **Tono:** Profesional y claro; priorizar lo que impacta fechas (go-live SEL Abril 2026) y riesgos (capacidad del equipo, dependencia del nuevo Data Engineer).
- **Próximos pasos:** Si conviene, cerrar el correo con 2–3 acciones clave de la próxima semana (ej. cerrar Fase 0 del plan SAP, siguiente ronda de entrevistas, validación de conciliación SEL con negocio).
- **Fechas:** Incluir el periodo que cubre el avance (ej. “Avance correspondiente a la semana del [fecha] al [fecha]”).
