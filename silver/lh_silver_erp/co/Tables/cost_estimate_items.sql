CREATE TABLE [co].[cost_estimate_items] (

	[sim] varchar(8000) NULL, 
	[material_id] varchar(8000) NULL, 
	[element] varchar(8000) NULL, 
	[cst_tl] decimal(38,10) NULL, 
	[cst_ll] decimal(38,10) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[user_id] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[percent_tl] decimal(38,10) NULL, 
	[percent_ll] decimal(38,10) NULL, 
	[ao] decimal(38,10) NULL, 
	[plant_id] varchar(8000) NULL, 
	[qadc01] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);