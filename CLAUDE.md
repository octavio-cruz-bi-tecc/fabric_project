# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

This repository contains **PySpark notebooks** for a **Microsoft Fabric** data lakehouse project. It implements a **Medallion architecture** (Bronze → Silver → Gold) to integrate data from two ERP systems: **QAD MFG** (current) and **SAP S/4 HANA Cloud** (being migrated to). All notebooks run inside Microsoft Fabric's Spark environment — they are not runnable locally.

## Architecture Overview

### Lakehouse Structure

| Layer | Lakehouses | Purpose |
|-------|-----------|---------|
| **Bronze** | `lh_bronze_qad1` (empresas SCO, SEL), `lh_bronze_qad2` (empresas PS/PRO, STU, SUS, HOS, IZD, IMA), `lh_bronze_sap` | Raw mirror of source ERP data |
| **Silver** | `lh_silver_erp` | Consolidated, standardized data (snake_case, English names, SAP-style naming) with QAD-like structure |
| **Gold** | `lh_gold_*` (e.g. `lh_gold_sales_and_distribution`) | Dimensional model (facts + dimensions) for reporting |
| **Control** | `lh_control_erp` | ETL control/watermark tables |

### Control Tables

All ETL is governed by metadata in `lh_control_erp`:

- `dbo.source_to_bronze_control` — QAD → Bronze (watermark, load_type, last_success_run_at)
- `dbo.source_to_bronze_control_sap` — SAP → Bronze (CDS-based)
- `dbo.bronze_to_silver_control` — Bronze QAD → Silver (watermark, column_mapping_json, primary_keys, updated_at_column)
- `dbo.bronze_to_silver_control_sap` — Bronze SAP → Silver
- `dbo.bronze_to_silver_sql_control` — SQL/view-based Silver flows
- `lh_silver_shortcuts.dbo.silver_to_gold_control` — Silver → Gold (business_keys, surrogate_key lookups, column_mapping_json)

### Key Columns (universal conventions)

- **`record_id`** — maps from `PROGRESS_RECID` (QAD's technical key)
- **`company_code`** — maps from `*_DOMAIN` fields in QAD (e.g. `PO_DOMAIN`, `AD_DOMAIN`)
- **`source_system`** — `'QAD'` or `'SAP'`, added during Silver transformation
- **`last_updated_at`** — always `current_timestamp()` at write time
- Company code normalization: `ST → STU`, `PS → PRO` (via `apply_company_code_fix`)

## Notebook Patterns

### Bronze notebooks (`notebooks/bronze/`)
- **`nb_merge_bronze_qad*.ipynb`** — Incremental merge from QAD staging table to Bronze Delta table. Uses `UPDT_LOG` audit table for deletes. Parameters: `table_name`, `table_name_temp`, `load_column`, `source_system`, `target_layer`.
- **`nb_logging_qad1_full.ipynb`** — Logs full loads.

### Silver notebooks (`notebooks/silver/`)
- **`nb_merge_silver_incremental.ipynb`** — Parametrized incremental ETL: Bronze → Silver. Reads `column_mapping_json` from the first cell parameters. Applies title_case UDF, deduplication by `record_id`/`company_code`, and Delta MERGE. Handles deletes via `UPDT_LOG` when `updated_at_column = 'UPDT_LOG'`.
- **`nb_materialize_silver_incremental.ipynb`** — Materializes a SQL view incrementally via `task_id` lookup in `bronze_to_silver_control`. Uses `materialize_sql` with `{WATERMARK_FILTER}` placeholder.
- **`nb_update_full_tables.ipynb`** — Full reload for Silver tables.

### Gold notebooks (`notebooks/gold/`)
- **`gold/sd/etl_facts.ipynb`**, **`gold/fi/etl_facts.ipynb`** — Load fact tables. Reads `task_id` config from `silver_to_gold_control`, performs dimension lookups via `column_mapping_json` (Type: `LOOKUP` or `DIRECT`), deduplicates, then MERGE into Gold.
- **`gold/sd/etl_dimensions*.ipynb`**, **`gold/fi/etl_dimensions.ipynb`**, **`gold/md/etl_dimensions.ipynb`** — Load dimension tables with surrogate keys.
- **`gold/md/etl_security.ipynb`** — Security/RLS dimension setup.

### Utility notebook
- **`nb_add_column_source_system.ipynb`** — Adds `source_system` column to existing Silver tables (migration utility).

## Common Code Patterns

### Concurrency retry (used everywhere)
All notebooks use exponential backoff for Delta Lake `ConcurrentAppendException`:
```python
MAX_RETRIES = 10
BASE_DELAY_SEC = 3
MAX_DELAY_SEC = 40
```

### Spark date config (always set at notebook start)
```python
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
```

### column_mapping_json format (Silver)
JSON array: `[{"source": "FIELD_NAME", "target": "snake_name", "cast": "STRING", "transform": "title_case"}, ...]`
- `source` may be a SQL expression (e.g. `UPPER(PT_PART)`, `COALESCE(PT_PROMO, ' ')`)
- `transform`: only `"title_case"` supported (Spanish-aware, lowercase prepositions/articles)

### column_mapping_json format (Gold)
JSON array: `[{"Type": "LOOKUP", "Source": "dim_table;fact_key1,fact_key2;dim_key1,dim_key2", "Target": "surrogate_key;alias"}, {"Type": "DIRECT", "Source": "col_name", "Target": "alias"}, ...]`

### Delta MERGE null-safe condition (Silver)
```python
# Keys in NULL_SAFE_KEYS use COALESCE; keys in NORMALIZE_KEYS use upper(trim(...))
NULL_SAFE_KEYS = {"company_code"}
NORMALIZE_KEYS = {"company_code"}
```

## SAP Integration Strategy

The chosen approach is **Strategy 3 (Silver dual + conforming layer)**:
1. `lh_silver_qad` (= current `lh_silver_erp`) remains untouched — fed by QAD Bronze only.
2. `lh_silver_sap` (new) — maps SAP CDS views to the same Silver schema (same column names, types, and QAD-like structure).
3. A conforming layer (`lh_silver_erp`) provides UNION ALL views or materialized tables combining both, with `source_system` and `company_code`.
4. Gold reads only from the conforming layer — transparent to end users.

SAP Bronze sources are **CDS views** (not raw transactional tables), ingested via SAP HANA connector on an on-premise Data Gateway (schema `SAPHANADB`). Pilot extractions: `IMATERIAL`, `I_CUSTOMER_CDS`, `ISDSALESORDER`, `IMATDOCITEM`.

**Go-live schedule** (relevant for filtering active source system per company):
- Feb 2026: 1st block of financial companies (already in SAP)
- Apr 2026: SEL
- May 2026: STU + 2nd block financials
- Jun 2026: SCO + last block financials

The 3 manufacturing companies (SEL, SCO, STU) drive the main datamarts in Gold.

## Repository Layout

```
notebooks/
  bronze/          # QAD → Bronze ETL notebooks
  silver/          # Bronze → Silver ETL notebooks
  gold/
    sd/            # Sales & Distribution (SD module)
    fi/            # Finance (FI module)
    md/            # Master data
csv/               # Mapping matrices and control data
avances/           # Weekly progress notes (Spanish)
Presentaciones/    # HTML/PDF presentations
documentos/        # Strategy and planning documents
```
