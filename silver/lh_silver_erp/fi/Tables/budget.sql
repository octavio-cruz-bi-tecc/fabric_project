CREATE TABLE [fi].[budget] (

	[budget_id] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[format_position_id] int NULL, 
	[budget_code] varchar(8000) NULL, 
	[entry_date] date NULL, 
	[entry_date_id] int NULL, 
	[budget_year] int NULL, 
	[budget_period] int NULL, 
	[amount] decimal(38,10) NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);