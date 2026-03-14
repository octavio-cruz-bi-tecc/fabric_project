CREATE TABLE [ecp].[payroll_periods] (

	[payroll_date] datetime2(6) NULL, 
	[npnsm] decimal(2,0) NULL, 
	[description] varchar(8000) NULL, 
	[npnqm] decimal(2,0) NULL, 
	[tipo] varchar(8000) NULL, 
	[bloq] int NULL, 
	[month] decimal(2,0) NULL, 
	[year] decimal(4,0) NULL, 
	[type_pr] varchar(8000) NULL, 
	[entpr_addr] varchar(8000) NULL, 
	[chr01] varchar(8000) NULL, 
	[chr02] varchar(8000) NULL, 
	[dec01] decimal(14,4) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);