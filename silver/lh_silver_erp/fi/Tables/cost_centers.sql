CREATE TABLE [fi].[cost_centers] (

	[cost_center_id] varchar(8000) NULL, 
	[description] varchar(8000) NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[is_active] bit NULL, 
	[category_id] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);