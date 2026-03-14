CREATE TABLE [pp].[mrp_run_result_items] (

	[dataset] varchar(8000) NULL, 
	[material_id] varchar(8000) NULL, 
	[mrp_number] varchar(8000) NULL, 
	[line_number] varchar(8000) NULL, 
	[release_date] datetime2(6) NULL, 
	[due_date] datetime2(6) NULL, 
	[quantity] decimal(38,10) NULL, 
	[mrp_type] varchar(8000) NULL, 
	[mrp_detail] varchar(8000) NULL, 
	[plant_id] varchar(8000) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[line_number2] varchar(8000) NULL, 
	[order_plant] varchar(8000) NULL, 
	[key_id] int NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);