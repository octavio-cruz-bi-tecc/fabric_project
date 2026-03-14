CREATE TABLE [md].[exchange_rates] (

	[curr1] varchar(8000) NULL, 
	[curr2] varchar(8000) NULL, 
	[start_date] datetime2(6) NULL, 
	[end_date] datetime2(6) NULL, 
	[rate] decimal(38,10) NULL, 
	[rate2] decimal(38,10) NULL, 
	[ratetype] varchar(8000) NULL, 
	[mod_userid] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);