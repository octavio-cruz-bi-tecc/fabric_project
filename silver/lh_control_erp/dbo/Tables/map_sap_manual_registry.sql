CREATE TABLE [dbo].[map_sap_manual_registry] (

	[target_table] varchar(8000) NULL, 
	[silver_column] varchar(8000) NULL, 
	[sap_object_name] varchar(8000) NULL, 
	[sap_column_name] varchar(8000) NULL, 
	[mapping_notes] varchar(8000) NULL, 
	[last_updated] datetime2(6) NULL, 
	[mapping_type] varchar(8000) NULL, 
	[sap_abap_name] varchar(8000) NULL, 
	[sap_description] varchar(8000) NULL
);