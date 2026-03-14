CREATE TABLE [fi].[check_register] (

	[ref] varchar(8000) NULL, 
	[status] varchar(8000) NULL, 
	[document_id] decimal(38,10) NULL, 
	[bank_id] varchar(8000) NULL, 
	[type_code] varchar(8000) NULL, 
	[comment_index] decimal(38,10) NULL, 
	[currency_code] varchar(8000) NULL, 
	[exchange_rate] decimal(38,10) NULL, 
	[voiddate] datetime2(6) NULL, 
	[voideff] datetime2(6) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[clr_date] datetime2(6) NULL, 
	[qadc01] varchar(8000) NULL, 
	[exchange_rate_2] decimal(38,10) NULL, 
	[exchange_rate_type] varchar(8000) NULL, 
	[exchange_rate_sequence] decimal(38,10) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);