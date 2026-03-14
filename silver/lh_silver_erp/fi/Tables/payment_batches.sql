CREATE TABLE [fi].[payment_batches] (

	[batch_id] varchar(8000) NULL, 
	[user_id] varchar(8000) NULL, 
	[date] datetime2(6) NULL, 
	[ctrl] decimal(38,10) NULL, 
	[total] decimal(38,10) NULL, 
	[bank_id] varchar(8000) NULL, 
	[status] varchar(8000) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[module] varchar(8000) NULL, 
	[doc_type_code] varchar(8000) NULL, 
	[beg_bal] decimal(38,10) NULL, 
	[qadc01] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);