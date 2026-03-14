CREATE TABLE [pp].[assignment_items] (

	[dataset] varchar(8000) NULL, 
	[order_number] varchar(8000) NULL, 
	[line_number] varchar(8000) NULL, 
	[plant_id] varchar(8000) NULL, 
	[storage_location_id] varchar(8000) NULL, 
	[material_id] varchar(8000) NULL, 
	[lot_number] varchar(8000) NULL, 
	[total_quantity] decimal(38,10) NULL, 
	[picked_quantity] decimal(38,10) NULL, 
	[quantity_change] decimal(38,10) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[reference] varchar(8000) NULL, 
	[order_plant] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);