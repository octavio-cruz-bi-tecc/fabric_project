CREATE TABLE [ecp].[companies] (

	[company_id] int NULL, 
	[company_code] varchar(8000) NULL, 
	[alias] varchar(8000) NULL, 
	[name] varchar(8000) NULL, 
	[short_name] varchar(8000) NULL, 
	[company_address] varchar(8000) NULL, 
	[work_address] varchar(8000) NULL, 
	[isvalid] bit NULL, 
	[type] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);