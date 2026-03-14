CREATE TABLE [fi].[fiscal_calendars] (

	[year] int NULL, 
	[period] int NULL, 
	[start] datetime2(6) NULL, 
	[end] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[yr_end] int NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);