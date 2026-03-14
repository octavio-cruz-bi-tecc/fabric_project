CREATE TABLE [aa].[asset_transactions] (

	[fixed_asset_id] varchar(8000) NULL, 
	[type] varchar(8000) NULL, 
	[amt] decimal(38,10) NULL, 
	[yrper] varchar(8000) NULL, 
	[life] int NULL, 
	[resrv] int NULL, 
	[famt_id] varchar(8000) NULL, 
	[fabk_id] varchar(8000) NULL, 
	[migrate] decimal(38,10) NULL, 
	[mod_userid] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[chr01] varchar(8000) NULL, 
	[dec01] int NULL, 
	[log01] int NULL, 
	[dte01] datetime2(6) NULL, 
	[int01] int NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);