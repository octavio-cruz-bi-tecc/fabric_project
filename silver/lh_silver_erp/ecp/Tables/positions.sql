CREATE TABLE [ecp].[positions] (

	[title_id] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[work_address] varchar(8000) NULL, 
	[members] int NULL, 
	[level] int NULL, 
	[leveltab] varchar(8000) NULL, 
	[chr01] varchar(8000) NULL, 
	[chr02] varchar(8000) NULL, 
	[chr03] varchar(8000) NULL, 
	[dec01] decimal(38,10) NULL, 
	[dec02] decimal(38,10) NULL, 
	[dec03] decimal(38,10) NULL, 
	[log01] bit NULL, 
	[titles_dte01] datetime2(6) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);