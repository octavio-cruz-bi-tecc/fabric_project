CREATE TABLE [fi].[machine_production] (

	[type] varchar(8000) NULL, 
	[plant_id] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[machine_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[effective_date] date NULL, 
	[date_id] int NULL, 
	[amount_produced] decimal(38,12) NULL, 
	[amount_returned] decimal(38,12) NULL, 
	[total_amount] decimal(38,12) NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);