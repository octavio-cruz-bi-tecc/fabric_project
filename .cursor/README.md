# Cursor – Skills y Reglas del proyecto

## Skill: fabric-medallion-policies

**Ubicación:** `.cursor/skills/fabric-medallion-policies/`

El agente aplica esta skill automáticamente cuando trabajas con:
- Tablas, pipelines, notebooks o lakehouses de Fabric
- SQL, ETL o lógica de carga
- Nomenclatura o arquitectura Medallion (Bronze, Silver, Gold)
- Integración SAP/QAD

**Referencia completa:** [Documentos/Politicas_Programacion_Fabric_Medallion.md](../Documentos/Politicas_Programacion_Fabric_Medallion.md)

---

## Regla: fabric-medallion-policies

**Ubicación:** `.cursor/rules/fabric-medallion-policies.mdc`

Se aplica cuando abres o editas archivos que coinciden con:
- `**/*.sql`
- `**/*.py`
- `bronze/**/*`
- `silver/**/*`
- `gold/**/*`

Inyecta un recordatorio conciso de nomenclatura y convenciones en el contexto del agente.

---

## Cómo usar

1. **Automático:** Al abrir archivos SQL o Python en carpetas bronze/silver/gold, la regla se activa.
2. **Skill:** Menciona explícitamente "Fabric", "Medallion", "nomenclatura" o "convenciones SAP" para que el agente use la skill.
3. **Manual:** Si quieres que la regla se aplique siempre, edita el `.mdc` y pon `alwaysApply: true`.
