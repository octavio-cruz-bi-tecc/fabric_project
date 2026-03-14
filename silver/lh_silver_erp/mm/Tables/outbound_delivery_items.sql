CREATE TABLE [mm].[outbound_delivery_items] (

	[shipd_nbr] varchar(8000) NULL, 
	[shipd_seq] varchar(8000) NULL, 
	[shipd_doc] varchar(8000) NULL, 
	[shipd_site] varchar(8000) NULL, 
	[shipd_doc_date] datetime2(6) NULL, 
	[shipd_addr] varchar(8000) NULL, 
	[shipd_city] varchar(8000) NULL, 
	[shipd_qty_ship] decimal(38,10) NULL, 
	[shipd_userid] varchar(8000) NULL, 
	[shipd_dec01] decimal(38,10) NULL, 
	[shipd_dec02] decimal(38,10) NULL, 
	[shipd_chr01] varchar(8000) NULL, 
	[shipd_chr02] varchar(8000) NULL, 
	[shipd_log01] int NULL, 
	[shipd_qty_kg] decimal(38,10) NULL, 
	[shipd_type] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] bigint NULL, 
	[last_updated_at] datetime2(6) NULL
);