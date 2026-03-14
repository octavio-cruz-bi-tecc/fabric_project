CREATE TABLE [fi].[financial] (

	[type] varchar(8000) NULL, 
	[scenario] varchar(8000) NULL, 
	[period] int NULL, 
	[year] int NULL, 
	[period_id] int NULL, 
	[format_position_id] int NULL, 
	[description] varchar(8000) NULL, 
	[account_id] varchar(8000) NULL, 
	[account_description] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[project_id] varchar(8000) NULL, 
	[total] decimal(38,10) NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);