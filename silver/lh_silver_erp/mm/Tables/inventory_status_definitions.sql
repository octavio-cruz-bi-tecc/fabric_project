CREATE TABLE [mm].[inventory_status_definitions] (

	[status] varchar(8000) NULL, 
	[avail] int NULL, 
	[nettable] int NULL, 
	[frozen] int NULL, 
	[overissue] int NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[user_id] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[desc] varchar(8000) NULL, 
	[cmtindx] int NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);