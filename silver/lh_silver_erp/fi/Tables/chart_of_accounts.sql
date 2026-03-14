CREATE TABLE [fi].[chart_of_accounts] (

	[account_id] varchar(8000) NULL, 
	[format_position] int NULL, 
	[account_type] varchar(8000) NULL, 
	[account_description] varchar(8000) NULL, 
	[currency_code] varchar(8000) NULL, 
	[is_active] bit NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[category_id] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL, 
	[character_02] varchar(8000) NULL, 
	[subcategory_id] varchar(8000) NULL, 
	[character_04] varchar(8000) NULL
);