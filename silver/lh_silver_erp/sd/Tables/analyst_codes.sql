CREATE TABLE [sd].[analyst_codes] (

	[user_id] varchar(8000) NULL, 
	[analysis_code] varchar(8000) NULL, 
	[cmtindx] int NULL, 
	[desc] varchar(8000) NULL, 
	[type] varchar(8000) NULL, 
	[sec_group] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[active] int NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);