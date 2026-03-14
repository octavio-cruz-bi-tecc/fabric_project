---
name: fabric-medallion-policies
description: Apply naming conventions, ETL procedures, and Medallion architecture standards for Microsoft Fabric (Bronze, Silver, Gold). Use when creating or modifying tables, pipelines, notebooks, lakehouses, SQL schemas, or ETL logic for SAP/QAD integration, or when the user asks about Fabric conventions, nomenclatura, or Medallion architecture.
---

# Fabric Medallion – Políticas de programación

Aplica estándares de nomenclatura, procedimientos de carga y convenciones para la arquitectura Medallion en Microsoft Fabric (integración SAP/QAD).

## Documento completo

Para referencia detallada: [Documentos/Politicas_Programacion_Fabric_Medallion.md](../../Documentos/Politicas_Programacion_Fabric_Medallion.md)

---

## Nomenclatura rápida

### Objetos Fabric
- **Workspaces:** `[ENV] - [Domain]` (ej. PROD - Data Engineering)
- **Artefactos:** `[prefix]_[snake_case]` → `lh_bronze_sap`, `lh_silver_erp`, `pl_load_bronze_qad`, `wh_finance`
- **Prefijos:** lh (Lakehouse), wh (Warehouse), pl (Pipeline), df (Dataflow), ds (Dataset), rp (Report)

### Tablas por capa
| Capa | Tablas | Columnas | Esquemas |
|------|--------|----------|----------|
| **Bronze** | Nombre original (QAD, SAP) | Original | QAD, SAPHANADB |
| **Silver** | snake_case | snake_case | sd, fi, co, mm, pp, md, ecp, qm, dbo |
| **Gold** | dim_*, fact_* | snake_case | Surrogate keys *_key |

### Silver multi-origen (QAD + SAP)
- Siempre incluir: `company_code`, `source_system` ('QAD' | 'SAP')

### Vistas / Procedimientos / Funciones
- Vista: `vw_<origen>_<área>_<nombre>`
- SP: `sp_<acción>_<área>_<objeto>`
- Función: `fn_<resultado>`

---

## Estrategia de carga

| Escenario | Estrategia |
|-----------|------------|
| Campo incremental (RECID, timestamp) | MERGE incremental; registrar en control |
| PK estable, sin incremental | Full con deduplicación; viable si <100k/día |
| Maestros pequeños | Overwrite programado |
| >500k registros/día | MERGE o snapshot particionado; evitar overwrite |

**Control tables:** source_to_bronze_control, bronze_to_silver_control, bronze_to_silver_control_sap, silver_to_gold_control.

---

## Convenciones QAD/SAP

- **QAD:** PROGRESS_RECID; *_DOMAIN → company_code; incremental vía UPDT_LOG
- **SAP:** Extraer CDS views (no tablas crudas); Full vs Delta según anotación CDS
- **Tablas XX (custom):** Una tabla Silver genérica por entidad; columnas nullable para diferencias entre orígenes

---

## Instrucciones para el agente

Al generar código o diseño:

1. Usar snake_case en Silver y Gold; mantener nombres originales en Bronze
2. Incluir `company_code` y `source_system` en tablas Silver multi-origen
3. Registrar flujos en tablas de control correspondientes
4. Elegir Full vs Incremental según escenario y volumen
5. Usar prefijos correctos para artefactos (lh_, pl_, wh_, etc.)
