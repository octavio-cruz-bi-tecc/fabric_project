CREATE TABLE [mm].[source_list_items] (

	[network] varchar(8000) NULL, 
	[rec_plant_id] varchar(8000) NULL, 
	[src_plant_id] varchar(8000) NULL, 
	[ref] varchar(8000) NULL, 
	[percent] int NULL, 
	[start] datetime2(6) NULL, 
	[end] datetime2(6) NULL, 
	[trans] varchar(8000) NULL, 
	[leadtime] int NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);