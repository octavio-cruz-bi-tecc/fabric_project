CREATE TABLE [mm].[landed_cost_details] (

	[internal_ref_type] varchar(8000) NULL, 
	[internal_reference] varchar(8000) NULL, 
	[shipfrom] varchar(8000) NULL, 
	[lc_charge] varchar(8000) NULL, 
	[log_supplier] varchar(8000) NULL, 
	[element] varchar(8000) NULL, 
	[accrual_level] varchar(8000) NULL, 
	[mod_userid] varchar(8000) NULL, 
	[mod_date] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);