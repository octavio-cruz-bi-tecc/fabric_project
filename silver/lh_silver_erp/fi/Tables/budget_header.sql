CREATE TABLE [fi].[budget_header] (

	[segment_id] varchar(8000) NULL, 
	[account_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[project_id] varchar(8000) NULL, 
	[format_position_id] int NULL, 
	[budget_account_id] varchar(8000) NULL, 
	[budget_cost_center_id] varchar(8000) NULL, 
	[budget_format_position_id] int NULL, 
	[budget_code] varchar(8000) NULL, 
	[user_1] varchar(8000) NULL, 
	[user_2] varchar(8000) NULL, 
	[sub_account_id] varchar(8000) NULL, 
	[budget_subaccount_id] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);