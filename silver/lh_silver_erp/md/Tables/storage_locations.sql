CREATE TABLE [md].[storage_locations] (

	[storage_location_id] varchar(8000) NULL, 
	[location_date] datetime2(6) NULL, 
	[perm_flag] int NULL, 
	[project_code] varchar(8000) NULL, 
	[plant_id] varchar(8000) NULL, 
	[status] varchar(8000) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[single_flag] int NULL, 
	[location_type] varchar(8000) NULL, 
	[capacity] decimal(38,10) NULL, 
	[capacity_unit] varchar(8000) NULL, 
	[description] varchar(8000) NULL, 
	[physical_address] varchar(8000) NULL, 
	[transfer_ownership_flag] int NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);