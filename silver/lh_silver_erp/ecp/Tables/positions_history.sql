CREATE TABLE [ecp].[positions_history] (

	[employee_id] varchar(8000) NULL, 
	[pre_title_id] varchar(8000) NULL, 
	[title_id] varchar(8000) NULL, 
	[pre_depart] varchar(8000) NULL, 
	[xxtitleh_initial_date] datetime2(6) NULL, 
	[xxtitleh_finish_date] datetime2(6) NULL, 
	[create_date] datetime2(6) NULL, 
	[create_usrid] varchar(8000) NULL, 
	[work_address] varchar(8000) NULL, 
	[chr01] varchar(8000) NULL, 
	[chr02] varchar(8000) NULL, 
	[chr03] varchar(8000) NULL, 
	[dat01] datetime2(6) NULL, 
	[dat02] datetime2(6) NULL, 
	[dat03] datetime2(6) NULL, 
	[log01] bit NULL, 
	[log02] bit NULL, 
	[log03] bit NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);