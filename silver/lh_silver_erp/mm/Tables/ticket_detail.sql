CREATE TABLE [mm].[ticket_detail] (

	[ticket_number] decimal(13,0) NULL, 
	[item_position] decimal(3,0) NULL, 
	[gross_weight] decimal(13,0) NULL, 
	[net_weight] decimal(13,0) NULL, 
	[weight_unit] varchar(8000) NULL, 
	[line_description] varchar(8000) NULL, 
	[time_stamp_text] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[last_updated_at] datetime2(6) NULL
);