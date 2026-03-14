CREATE TABLE [fi].[financial_categories] (

	[category_id] varchar(8000) NULL, 
	[category_type] varchar(8000) NULL, 
	[category_description] varchar(8000) NULL, 
	[is_active] bit NULL, 
	[created_date] datetime2(6) NULL, 
	[updated_date] datetime2(6) NULL, 
	[sort_order] int NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);