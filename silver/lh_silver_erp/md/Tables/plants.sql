CREATE TABLE [md].[plants] (

	[plant_id] varchar(8000) NULL, 
	[plant_description] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[status] varchar(8000) NULL, 
	[auto_location_code] decimal(18,2) NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[custom_text_1] varchar(8000) NULL, 
	[custom_text_2] varchar(8000) NULL, 
	[git_account] varchar(8000) NULL, 
	[git_cost_center] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[plant_type] int NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);