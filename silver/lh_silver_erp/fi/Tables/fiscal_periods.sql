CREATE TABLE [fi].[fiscal_periods] (

	[year] int NULL, 
	[period] int NULL, 
	[segment_id] varchar(8000) NULL, 
	[gl_clsd] int NULL, 
	[closed] int NULL, 
	[yr_clsd] int NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);