CREATE TABLE [md].[units_of_measure] (

	[unit_of_measure] varchar(8000) NULL, 
	[alternate_unit] varchar(8000) NULL, 
	[conversion_factor] decimal(38,10) NULL, 
	[part_number] varchar(8000) NULL, 
	[description] varchar(8000) NULL, 
	[alternate_quantity] decimal(38,10) NULL, 
	[allowed_decimals] int NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);