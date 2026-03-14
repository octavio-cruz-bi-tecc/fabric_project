CREATE TABLE [fi].[budget_line_items] (

	[account_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[project_id] varchar(8000) NULL, 
	[entry_date] date NULL, 
	[budget_year] int NULL, 
	[budget_period] int NULL, 
	[amount] decimal(38,10) NULL, 
	[percentage] decimal(38,10) NULL, 
	[format_position_id] int NULL, 
	[segment_id] varchar(8000) NULL, 
	[budget_code] varchar(8000) NULL, 
	[user_1] varchar(8000) NULL, 
	[user_2] varchar(8000) NULL, 
	[user_id] varchar(8000) NULL, 
	[created_date] date NULL, 
	[subaccount_id] varchar(8000) NULL, 
	[currency_amount] decimal(38,10) NULL, 
	[exchange_rate] decimal(20,10) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);