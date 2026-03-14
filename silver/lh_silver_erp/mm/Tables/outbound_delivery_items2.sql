CREATE TABLE [mm].[outbound_delivery_items2] (

	[shipment_number] varchar(8000) NULL, 
	[sequence_number] varchar(8000) NULL, 
	[delivery_document] varchar(8000) NULL, 
	[comment_line_1] varchar(8000) NULL, 
	[comment_line_2] varchar(8000) NULL, 
	[comment_line_3] varchar(8000) NULL, 
	[comment_line_4] varchar(8000) NULL, 
	[comment_line_5] varchar(8000) NULL, 
	[ship_dec01] int NULL, 
	[ship_dec02] int NULL, 
	[ship_log01] int NULL, 
	[ship_log02] int NULL, 
	[ship_dte01] datetime2(6) NULL, 
	[ship_dte02] datetime2(6) NULL, 
	[ship_chr01] varchar(8000) NULL, 
	[ship_chr02] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);