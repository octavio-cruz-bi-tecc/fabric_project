CREATE TABLE [co].[allocation_rule_items] (

	[allocation_code] varchar(8000) NULL, 
	[account_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[project_id] varchar(8000) NULL, 
	[pct] decimal(38,10) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[subaccount_id] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);