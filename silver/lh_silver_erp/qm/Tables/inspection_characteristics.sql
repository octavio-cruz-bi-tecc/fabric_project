CREATE TABLE [qm].[inspection_characteristics] (

	[parameter_id] varchar(8000) NULL, 
	[parameter_type] varchar(8000) NULL, 
	[parameter_label] varchar(8000) NULL, 
	[tolerance] decimal(18,2) NULL, 
	[tolerance_type] varchar(8000) NULL, 
	[comment_index] int NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[chr_field_01] varchar(8000) NULL, 
	[chr_field_02] varchar(8000) NULL, 
	[chr_field_03] varchar(8000) NULL, 
	[dec_field_01] decimal(18,2) NULL, 
	[dec_field_02] decimal(18,2) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);