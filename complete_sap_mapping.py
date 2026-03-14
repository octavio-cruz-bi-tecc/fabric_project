#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Completa las filas lh_bronze_sap_rise en Matriz_Mapeo_ERP.csv:
- source_table: CDS View (SQL View Name) que mejor se ajusta al target_table Silver
- Campo_001..Campo_209: nombre del campo de la CDS View que mapea a cada campo Silver (vacío si no aplica)
- Nuevas columnas sap_Campo_001..sap_Campo_010 al final para campos exclusivos SAP (Client, CreatedBy, etc.)
"""

import csv
import re
from pathlib import Path

# Mapeo target_table Silver -> (CDS View SQL Name, dict Silver_field -> SAP_CDS_field para los que conocemos)
# Campos genéricos se resuelven por convención al final (company_code->CompanyCode, etc.)
TARGET_TO_CDS_AND_FIELDS = {
    # AA - Activos
    "asset_balance_details": ("IASHV", {"fixed_asset_id": "Subnumber", "account_type": "AssetTransactionType", "account_id": "GLAccount", "subaccount_id": "GLAccountInChartOfAccounts", "cost_center_id": "CostCenter", "project_id": "WBSElementInternalID", "company_code": "CompanyCode"}),
    "asset_budget_details": ("IASHV", {"fixed_asset_id": "Subnumber", "company_code": "CompanyCode"}),
    "asset_transactions": ("IASHV", {"fixed_asset_id": "Subnumber", "company_code": "CompanyCode"}),
    "fixed_assets": ("IASHV", {"fixed_asset_id": "Asset", "segment_id": "Segment", "desc1": "AssetDescription", "company_code": "CompanyCode"}),
    # CO
    "allocation_rule_items": ("ICOSTCENTER", {"allocation_code": "CostCenter", "cost_center_id": "CostCenter", "company_code": "CompanyCode"}),
    "allocation_rules": ("ICOSTCENTER", {"allocation_code": "CostCenter", "company_code": "CompanyCode"}),
    "cost_components": ("ICOSTELEMENT", {"element": "CostElement", "desc": "CostElementName", "company_code": "CompanyCode"}),
    "cost_estimate": ("ICOSTCENTER", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "cost_estimate_items": ("ICOSTELEMENT", {"material_id": "Material", "element": "CostElement", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "cost_centers": ("ICOSTCENTER", {"company_code": "CompanyCode"}),
    # ECP - Empresa/HR custom (SAP: Business Partner, Company Code; muchos sin CDS directo)
    "companies": ("ICOMPANYCODE", {"company_id": "CompanyCode", "company_code": "CompanyCode"}),
    "company_codes": ("ICOMPANYCODE", {"company_code": "CompanyCode"}),
    "employees": ("IBUSINESSPART", {}),  # BP puede tener empleados
    "employee_items": ("IBUSINESSPART", {}),
    "job_titles": ("", {}),  # Custom ECP
    "payroll_companies": ("ICOMPANYCODE", {"company_code": "CompanyCode"}),
    "payroll_concepts": ("", {}),
    "payroll_control": ("", {}),
    "payroll_groups": ("", {}),
    "payroll_periods": ("IFISCALYEAR", {"fiscal_year": "FiscalYear", "company_code": "CompanyCode"}),
    "payroll_register": ("IFIGLITM", {"company_code": "CompanyCode", "amount": "AmountInCompanyCodeCurrency"}),
    "positions": ("IPOSITION", {"position_id": "Position", "description": "PositionDescription", "company_code": "CompanyCode"}),
    "positions_history": ("IPOSITION", {"company_code": "CompanyCode"}),
    "work_companies": ("ICOMPANYCODE", {"company_code": "CompanyCode"}),
    # FI
    "account_assignment_structure": ("IGLACCOUNTINCHARTOFACCOUNTS", {"account_id": "GLAccount", "cost_center_id": "CostCenter", "company_code": "CompanyCode"}),
    "account_balance_items": ("IACCDOCITEM", {"account_id": "GLAccount", "cost_center_id": "CostCenter", "segment_id": "Segment", "project_id": "WBSElementInternalID", "year": "FiscalYear", "period": "FiscalPeriod", "amount": "AmountInCompanyCodeCurrency", "currency_amount": "TransactionCurrencyAmount", "company_code": "CompanyCode"}),
    "accounts_payable": ("IFISLI", {"ref": "AccountingDocument", "supplier_id": "Supplier", "effective_date": "DocumentDate", "date": "PostingDate", "amount": "AmountInCompanyCodeCurrency", "gl_account_id": "GLAccount", "cost_center_id": "CostCenter", "currency_code": "TransactionCurrency", "company_code": "CompanyCode"}),
    "accounts_receivable": ("IFICLI", {"document_type": "DocumentType", "document_id": "AccountingDocument", "customer_account": "Customer", "sales_order_id": "SalesOrder", "effective_date": "DocumentDate", "posting_date": "PostingDate", "amount": "AmountInCompanyCodeCurrency", "account_id": "GLAccount", "cost_center_id": "CostCenter", "currency_code": "TransactionCurrency", "company_code": "CompanyCode"}),
    "accounts_receivable_items": ("IACCDOCITEM", {"document_id": "AccountingDocument", "account_id": "GLAccount", "cost_center_id": "CostCenter", "amount": "AmountInCompanyCodeCurrency", "company_code": "CompanyCode"}),
    "ap_invoices": ("IFISLI", {"ref": "AccountingDocument", "supplier_id": "Supplier", "amount_change": "AmountInCompanyCodeCurrency", "currency_code": "TransactionCurrency", "company_code": "CompanyCode"}),
    "chart_of_accounts": ("IGLACCOUNTINCHARTOFACCOUNTS", {"company_code": "CompanyCode"}),
    "journal_posting_items": ("IFIGLITM", {"company_code": "CompanyCode", "account_id": "GLAccount", "cost_center_id": "CostCenter", "amount": "AmountInCompanyCodeCurrency"}),
    "universal_journal_entries": ("IFIGLITM", {"company_code": "CompanyCode", "account_id": "GLAccount", "cost_center_id": "CostCenter"}),
    "payment_batches": ("IPAYMENTRUN", {"company_code": "CompanyCode"}),
    "payment_cleared_items": ("IFISLI", {"company_code": "CompanyCode"}),
    "payment_terms": ("IPAYMENTTERMS", {"payment_terms_id": "PaymentTerms", "description": "PaymentTermsName", "company_code": "CompanyCode"}),
    "subaccounts": ("IGLACCOUNTINCHARTOFACCOUNTS", {"company_code": "CompanyCode"}),
    "currencies": ("ICURRENCY", {}),
    "exchange_rates": ("IEXCHANGERATE", {"from_currency": "SourceCurrency", "to_currency": "TargetCurrency", "effective_date": "ExchangeRateDate", "company_code": "CompanyCode"}),
    "fiscal_calendars": ("IFISCALYEAR", {"company_code": "CompanyCode"}),
    "fiscal_periods": ("IFISCALYEAR", {"company_code": "CompanyCode"}),
    "segments": ("ISEGMENT", {"company_code": "CompanyCode"}),
    # SD
    "sales_order": ("ISALESORDER", {"company_code": "SalesOrganization", "sales_order_id": "SalesOrder"}),
    "sales_order_items": ("ISALESORDERITM", {"sales_order_id": "SalesOrder", "material_id": "Material", "plant_id": "Plant", "quantity": "RequestedQuantity", "company_code": "SalesOrganization"}),
    "invoices": ("IBILLINGDOC", {"document_id": "BillingDocument", "customer_account": "SoldToParty", "company_code": "CompanyCode"}),
    "invoice_items": ("IBILLINGDOCUMENTITEM", {"document_id": "BillingDocument", "material_id": "Material", "amount": "TransactionCurrencyAmount", "company_code": "CompanyCode"}),
    "outbound_delivery": ("IDELIVDOC", {"company_code": "CompanyCode"}),
    "outbound_delivery_items": ("IDELIVERYDOCUMENTITEM", {"company_code": "CompanyCode"}),
    "outbound_delivery_items2": ("IDELIVERYDOCUMENTITEM", {}),
    "customers": ("ICUSTOMER", {"company_code": "CompanyCode"}),
    "business_partner": ("IBUSINESSPART", {"company_code": "CompanyCode"}),
    "sales_quotation": ("ISALESDOCUMENT", {}),
    "sales_quotation_items": ("ISALESDOCUMENTITEM", {}),
    # MM
    "purchase_order": ("IPURCHASEORDER", {"company_code": "CompanyCode", "purchase_order_id": "PurchaseOrder"}),
    "purchase_order_items": ("IPURCHASEORDERIT", {"purchase_order_id": "PurchaseOrder", "material_id": "Material", "plant_id": "Plant", "quantity": "RequestedQuantity", "company_code": "CompanyCode"}),
    "purchase_requisition_items": ("IPURCHASEREQITEM", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "stock_transport_requisitions": ("IPURCHASEREQ", {"company_code": "CompanyCode"}),
    "stock_transport_requisition_items": ("IPURCHASEREQITEM", {}),
    "material_inventory": ("IMATSTOCK", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "material_document_items": ("IMATDOCITEM", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "material_documents_history": ("IMATDOCITEM", {"company_code": "CompanyCode"}),
    "materials": ("IPRODUCT", {"material_id": "Product", "company_code": "CompanyCode"}),
    "plants": ("IPLANT", {"plant_id": "Plant", "company_code": "CompanyCode"}),
    "storage_locations": ("ISTORAGELOCATION", {"plant_id": "Plant", "company_code": "CompanyCode"}),
    "suppliers": ("ISUPPLIER", {"company_code": "CompanyCode"}),
    "stock_transport_order": ("IPURCHASEORDER", {}),
    "stock_transport_order_items": ("IPURCHASEORDERIT", {}),
    # PP
    "production_order_header": ("IPRODORDER", {"company_code": "CompanyCode", "plant_id": "Plant", "material_id": "Material"}),
    "production_order_routing": ("IPRODORDEROPERATION", {"company_code": "CompanyCode", "plant_id": "Plant"}),
    "production_order_assignments": ("IPRODORDEROPERATION", {}),
    "bill_of_material": ("IBOMITEM", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "bill_of_material_header": ("IBOMHEADER", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "routing_operations": ("IPRODUCTROUTING", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "work_centers": ("IWORKCENTER", {"plant_id": "Plant", "company_code": "CompanyCode"}),
    # PM
    "assets": ("IASHV", {"company_code": "CompanyCode"}),
    # QM
    "inspection_characteristics": ("IINSPECTIONOPERATION", {"company_code": "CompanyCode"}),
    # Cross / Otros
    "countries": ("ICOUNTRY", {"country_code": "Country", "description": "CountryName"}),
    "units_of_measure": ("IUNITOFMEASURE", {"unit_of_measure_code": "UnitOfMeasure", "description": "Description"}),
    "tax_codes": ("ITAXCODE", {"tax_code": "TaxCode", "description": "TaxCodeName", "company_code": "CompanyCode"}),
    "tax_code_details": ("ITAXCODE", {"tax_code": "TaxCode", "company_code": "CompanyCode"}),
    "incoterms": ("IINCOTERMS", {"incoterms": "IncotermsClassification", "description": "IncotermsDescription"}),
    "projects": ("IPROJECT", {"project_id": "WBSElement", "description": "WBSElementDescription", "company_code": "CompanyCode"}),
    "format_positions": ("", {}),
    "general_codes": ("", {}),
    "comments": ("", {}),
    "standard_texts": ("", {}),
    "user_master": ("", {}),
    "user_details": ("", {}),
    "supplier_invoice": ("IFISLI", {"company_code": "CompanyCode"}),
    "supplier_invoice_items": ("IFISLI", {}),
    "supplier_invoice_gl_details": ("IACCDOCITEM", {}),
    "supplier_bank_accounts": ("IBANKACCOUNT", {"supplier_id": "BusinessPartner", "company_code": "CompanyCode"}),
    "supplier_payment_history": ("IFISLI", {"company_code": "CompanyCode"}),
    "customer_materials": ("ICUSTOMERMATERIAL", {"customer_id": "Customer", "material_id": "Material", "company_code": "CompanyCode"}),
    "customers_comments": ("", {}),
    "sales_employee": ("ISALESEMPLOYEE", {"employee_id": "SalesEmployee", "company_code": "CompanyCode"}),
    "sales_account_determinations": ("", {}),
    "pricing_conditions": ("ICONDITIONRECORD", {"company_code": "CompanyCode"}),
    "purchasing_conditions": ("IPURCHASEINFORECORD", {"material_id": "Material", "supplier_id": "Supplier", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "purchasing_info_records": ("IPURCHASEINFORECORD", {"material_id": "Material", "supplier_id": "Supplier", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "freight_master": ("", {}),
    "freight_order": ("", {}),
    "freight_order_items": ("", {}),
    "freight_condition_rates": ("", {}),
    "freight_zones": ("", {}),
    "landed_cost_condition_types": ("", {}),
    "landed_cost_details": ("", {}),
    "return_types": ("", {}),
    "return_type_items": ("", {}),
    "request_return": ("IRETURNDELIVERY", {"company_code": "CompanyCode", "return_document": "ReturnsDocument"}),
    "request_return_items": ("IRETURNDELIVERYITEM", {"company_code": "CompanyCode"}),
    "rejections": ("IRETURNDELIVERY", {}),
    "rejection_items": ("IRETURNDELIVERYITEM", {}),
    "material_plant_parameters": ("IPRODUCT", {"plant_id": "Plant", "company_code": "CompanyCode"}),
    "source_list_header": ("ISOURCELIST", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "source_list_items": ("ISOURCELIST", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "material_stock_loc": ("IMATSTOCK", {}),
    "material_feasibility": ("", {}),
    "material_feasibility_items1": ("", {}),
    "material_feasibility_items2": ("", {}),
    "material_deviations": ("", {}),
    "cycle_count_document_header": ("IINVENTORYCOUNTDOC", {"company_code": "CompanyCode", "plant_id": "Plant"}),
    "cycle_count_document_items": ("IINVENTORYCOUNTDOCITEM", {"company_code": "CompanyCode"}),
    "inventory_status_definitions": ("", {}),
    "inventory_status_movement_controls": ("", {}),
    "price_change_request": ("", {}),
    "accessorial_charge_conditions": ("ICONDITIONRECORD", {}),
    "budget_header": ("ICSTCNTRBDGT", {"cost_center_id": "CostCenter", "fiscal_year": "FiscalYear", "company_code": "CompanyCode"}),
    "budget_line_items": ("ICSTCNTRBDGT", {"cost_center_id": "CostCenter", "company_code": "CompanyCode"}),
    "budget_work_center": ("IWORKCENTER", {"work_center_id": "WorkCenter", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "assignment_items": ("", {}),
    "assignment_complement_items": ("", {}),
    "analyst_codes": ("ISALESEMPLOYEE", {"company_code": "CompanyCode"}),
    "bank_master": ("IHOUSEBANK", {"bank_id": "HouseBank", "company_code": "CompanyCode", "description": "HouseBankName"}),
    "check_register": ("IPAYMENTDOC", {"company_code": "CompanyCode", "payment_document": "PaymentDocument"}),
    "cross_references": ("", {}),
    "e_documents_history": ("IACCDOC", {"company_code": "CompanyCode", "document_id": "AccountingDocument"}),
    "parked_journal_entries": ("IACCDOC", {"company_code": "CompanyCode", "document_type": "AccountingDocumentType"}),
    "process_log_history": ("", {}),
    "product_lines": ("", {}),
    "rpa_control": ("", {}),
    "tax_environment_master": ("", {}),
    "tax_environment_details": ("", {}),
    "tax_transaction_details": ("", {}),
    "ticket_master": ("", {}),
    "ticket_detail": ("", {}),
    "user_det1": ("", {}),
    "user_det2": ("", {}),
    "user_group_master": ("", {}),
    "custom_transaction_history": ("", {}),
    "sales_order_parent_child_history": ("ISALESORDER", {"sales_order_id": "SalesOrder", "company_code": "SalesOrganization"}),
    "mrp_run_result_items": ("IPLANNEDORDER", {"material_id": "Material", "plant_id": "Plant", "company_code": "CompanyCode"}),
    "feasibility_analysis": ("", {}),
    "feasibility_analysis_items": ("", {}),
}

# Convención genérica: Silver field name -> SAP CDS field name (cuando no hay mapeo específico)
SILVER_TO_SAP_GENERIC = {
    "company_code": "CompanyCode",
    "cost_center_id": "CostCenter",
    "account_id": "GLAccount",
    "subaccount_id": "GLAccountInChartOfAccounts",
    "material_id": "Material",
    "plant_id": "Plant",
    "supplier_id": "Supplier",
    "customer_account": "Customer",
    "customer_id": "Customer",
    "project_id": "WBSElementInternalID",
    "segment_id": "Segment",
    "amount": "AmountInCompanyCodeCurrency",
    "currency_code": "TransactionCurrency",
    "currency_amount": "TransactionCurrencyAmount",
    "effective_date": "DocumentDate",
    "posting_date": "PostingDate",
    "date": "DocumentDate",
    "mod_date": "LastChangeDate",
    "last_updated_at": "LastChangeDateTime",
    "description": "Description",
    "desc": "Description",
    "desc1": "Name",
}

# Campos exclusivos SAP a añadir al final (columnas sap_Campo_001, ...)
SAP_ONLY_FIELDS = [
    "sap_Client",           # MANDT
    "sap_CreatedBy",
    "sap_CreatedOn",
    "sap_LastChangedBy",
    "sap_LastChangedOn",
    "sap_DataSource",
    "sap_LogicalSystem",
    "sap_DataPackage",
]

def normalize_silver_field(name):
    if not name or name.startswith("current_timestamp"):
        return None
    return (name or "").strip().lower()

def get_sap_field_for_silver(silver_field, target_table, target_to_cds_and_fields):
    """Devuelve el nombre del campo SAP CDS que mapea a silver_field."""
    if not silver_field or "current_timestamp" in str(silver_field):
        return ""
    # No mapear genéricamente campos custom/user/extensible (dejar vacío para revisión manual)
    if (silver_field.startswith("custom_") or silver_field.startswith("user") or
        silver_field.startswith("chr") or silver_field.startswith("dec") or
        silver_field.startswith("log") or silver_field.startswith("dte") or silver_field.startswith("udf_")):
        # Solo devolver algo si hay mapeo específico para esta tabla
        if target_table in target_to_cds_and_fields:
            _, field_map = target_to_cds_and_fields[target_table]
            if silver_field in field_map:
                return field_map[silver_field]
        return ""
    # Campos de control Silver: record_id no existe en SAP; last_updated_at -> LastChangeDateTime
    if silver_field == "record_id":
        return ""
    if silver_field == "last_updated_at":
        return "LastChangeDateTime"
    # Mapeo específico de la tabla (field_map es el dict dentro de la tupla)
    if target_table in target_to_cds_and_fields:
        _, field_map = target_to_cds_and_fields[target_table]
        if silver_field in field_map:
            return field_map[silver_field]
    # Convención genérica por nombre
    for gen_silver, gen_sap in SILVER_TO_SAP_GENERIC.items():
        if gen_silver in silver_field or silver_field == gen_silver:
            return gen_sap
    return ""

def main():
    base = Path(__file__).parent
    csv_path = base / "Matriz_Mapeo_ERP.csv"
    with open(csv_path, "r", encoding="utf-8", newline="") as f:
        reader = csv.reader(f)
        rows = list(reader)

    if not rows:
        return
    header = rows[0]
    # Si el encabezado ya tiene columnas sap_, no duplicar
    if any(c.startswith("sap_") for c in header):
        sap_col_count = sum(1 for c in header if c.startswith("sap_"))
        new_header = header
        # Índice donde empiezan las columnas sap_* (por si hay Notas_SAP u otras después)
        if "sap_Client" in header:
            base_header_len = header.index("sap_Client")
        else:
            base_header_len = len(header) - sap_col_count
    else:
        base_header_len = len(header)
        new_header = header + list(SAP_ONLY_FIELDS)
        rows[0] = new_header
    # Asegurar que todas las filas tengan la misma longitud que el encabezado
    for idx in range(1, len(rows)):
        while len(rows[idx]) < len(new_header):
            rows[idx].append("")

    # Construir índice: por cada fila lh_bronze_sap_rise, tenemos target_table del grupo
    # Recorremos por grupos: Silver (lh_silver_erp), luego QAD(s), luego SAP (lh_bronze_sap_rise)
    i = 1
    while i < len(rows):
        row = rows[i]
        if len(row) < 5:
            i += 1
            continue
        lakehouse = (row[0] or "").strip()
        target_table = (row[3] or "").strip() if len(row) > 3 else ""

        if lakehouse == "lh_silver_erp" and target_table:
            # Este es el inicio de un grupo. Recoger campos Silver (desde col 4 en adelante)
            silver_fields = []
            for j in range(4, len(row)):
                if row[j]:
                    silver_fields.append((j, row[j]))
                elif silver_fields and j < 50:  # permitir algún hueco
                    continue
                elif silver_fields:
                    break
            # Avanzar hasta encontrar lh_bronze_sap_rise con el mismo target_table
            k = i + 1
            while k < len(rows):
                r = rows[k]
                if len(r) < 4:
                    k += 1
                    continue
                lh = (r[0] or "").strip()
                tt = (r[3] or "").strip() if len(r) > 3 else ""
                if lh == "lh_bronze_sap_rise" and tt == target_table:
                    # Rellenar esta fila SAP
                    cds_view, field_map = TARGET_TO_CDS_AND_FIELDS.get(target_table, ("", {}))
                    # source_table = CDS View (SQL Name)
                    r[2] = cds_view  # source_table es columna índice 2 (0-based)
                    # Rellenar campos Campo_001.. según posición Silver
                    for col_idx, silver_f in silver_fields:
                        if col_idx < len(r):
                            silver_norm = normalize_silver_field(silver_f)
                            sap_f = get_sap_field_for_silver(silver_norm, target_table, TARGET_TO_CDS_AND_FIELDS)
                            if not sap_f and silver_norm:
                                sap_f = SILVER_TO_SAP_GENERIC.get(silver_norm, "")
                            r[col_idx] = sap_f or r[col_idx]
                    # Extender fila si es más corta que el header (para las nuevas columnas sap_)
                    while len(r) < len(new_header):
                        r.append("")
                    # Rellenar sap_ al final (columnas añadidas después de Campo_209)
                    base_len = base_header_len
                    for si, sap_name in enumerate(SAP_ONLY_FIELDS):
                        idx = base_len + si
                        if idx < len(r):
                            # Valor sugerido para el campo exclusivo SAP
                            if "Client" in sap_name:
                                r[idx] = "Client"
                            elif "CreatedBy" in sap_name:
                                r[idx] = "CreatedByUser"
                            elif "CreatedOn" in sap_name:
                                r[idx] = "CreationDate"
                            elif "LastChangedBy" in sap_name:
                                r[idx] = "LastChangedByUser"
                            elif "LastChangedOn" in sap_name:
                                r[idx] = "LastChangeDate"
                            elif "DataSource" in sap_name:
                                r[idx] = "DataSource"
                            elif "LogicalSystem" in sap_name:
                                r[idx] = "LogicalSystem"
                            elif "DataPackage" in sap_name:
                                r[idx] = "DataPackage"
                            else:
                                r[idx] = sap_name
                    rows[k] = r
                    break
                if lh == "lh_silver_erp":
                    break  # siguiente grupo
                k += 1
        i += 1

    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerows(rows)
    print("Matriz actualizada: source_table y campos SAP rellenados; columnas sap_* añadidas.")

if __name__ == "__main__":
    main()
