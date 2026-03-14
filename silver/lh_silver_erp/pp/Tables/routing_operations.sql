CREATE TABLE [pp].[routing_operations] (

	[routing_id] varchar(8000) NULL, 
	[operation_number] varchar(8000) NULL, 
	[operation_description] varchar(8000) NULL, 
	[work_center_id] varchar(8000) NULL, 
	[machine_id] varchar(8000) NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[modified_date] date NULL, 
	[modified_by] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);