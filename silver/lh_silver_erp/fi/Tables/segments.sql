CREATE TABLE [fi].[segments] (

	[segment_id] varchar(8000) NULL, 
	[name] varchar(8000) NULL, 
	[primary] int NULL, 
	[currency_code] varchar(8000) NULL, 
	[user1] varchar(8000) NULL, 
	[user2] varchar(8000) NULL, 
	[adj_bs] int NULL, 
	[page_num] int NULL, 
	[next_prot] int NULL, 
	[src_desc_lang] varchar(8000) NULL, 
	[address_id] varchar(8000) NULL, 
	[consolidation] int NULL, 
	[type] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);