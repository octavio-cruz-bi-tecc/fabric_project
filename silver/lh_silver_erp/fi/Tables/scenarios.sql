CREATE TABLE [fi].[scenarios] (

	[scenario_id] varchar(8000) NULL, 
	[scenario_description] varchar(8000) NULL, 
	[category] varchar(8000) NULL, 
	[created_date] datetime2(6) NULL, 
	[updated_date] datetime2(6) NULL, 
	[sort_order] int NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);