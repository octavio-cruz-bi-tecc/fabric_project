CREATE TABLE [md].[customers_comments] (

	[customer_id] varchar(8000) NULL, 
	[comment] varchar(8000) NULL, 
	[day_grace] int NULL, 
	[comment_themes] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[source_oid] decimal(38,0) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);