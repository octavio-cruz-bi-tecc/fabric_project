CREATE TABLE [fi].[format_positions] (

	[format_position_id] int NULL, 
	[description] varchar(8000) NULL, 
	[sums_into] int NULL, 
	[type] varchar(8000) NULL, 
	[dr_cr_credit] bit NULL, 
	[page_break] bit NULL, 
	[is_header] bit NULL, 
	[is_total] bit NULL, 
	[skip_line] bit NULL, 
	[underline] bit NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[cost_center_sort] bit NULL, 
	[subaccount_sort] bit NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);