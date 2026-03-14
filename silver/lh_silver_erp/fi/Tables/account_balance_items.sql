CREATE TABLE [fi].[account_balance_items] (

	[account_id] varchar(8000) NULL, 
	[cost_center_id] varchar(8000) NULL, 
	[segment_id] varchar(8000) NULL, 
	[project_id] varchar(8000) NULL, 
	[year] int NULL, 
	[period] int NULL, 
	[amount] decimal(38,10) NULL, 
	[currency_amount] decimal(38,10) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[gl_subaccount_id] varchar(8000) NULL, 
	[ecur_amount] decimal(38,10) NULL, 
	[qadc01] varchar(8000) NULL, 
	[dr_amount] decimal(38,10) NULL, 
	[cr_amount] decimal(38,10) NULL, 
	[cr_currency_amount] decimal(38,10) NULL, 
	[dr_currency_amount] decimal(38,10) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);