CREATE TABLE [ecp].[work_companies] (

	[work_address] varchar(8000) NULL, 
	[description] varchar(8000) NULL, 
	[group] varchar(8000) NULL, 
	[chr01] varchar(8000) NULL, 
	[chr02] varchar(8000) NULL, 
	[chr03] varchar(8000) NULL, 
	[dec01] decimal(10,0) NULL, 
	[dec02] decimal(10,0) NULL, 
	[dec03] decimal(10,0) NULL, 
	[log01] bit NULL, 
	[log02] bit NULL, 
	[log03] bit NULL, 
	[date01] datetime2(6) NULL, 
	[date02] datetime2(6) NULL, 
	[date03] datetime2(6) NULL, 
	[oid_xxentwk_mstr] decimal(10,0) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);