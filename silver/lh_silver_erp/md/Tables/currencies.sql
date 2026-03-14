CREATE TABLE [md].[currencies] (

	[currency_code] varchar(8000) NULL, 
	[desc] varchar(8000) NULL, 
	[rnd_mthd] varchar(8000) NULL, 
	[active] int NULL, 
	[mod_userid] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[iso_currency_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);