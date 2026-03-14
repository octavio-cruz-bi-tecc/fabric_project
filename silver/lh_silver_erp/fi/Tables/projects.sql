CREATE TABLE [fi].[projects] (

	[project_id] varchar(8000) NULL, 
	[description] varchar(8000) NULL, 
	[is_active] bit NULL, 
	[begin_date] date NULL, 
	[comment_index] int NULL, 
	[comp_date] date NULL, 
	[finish_date] date NULL, 
	[revised_date] date NULL, 
	[revised_finish_date] date NULL, 
	[status] varchar(8000) NULL, 
	[type] varchar(8000) NULL, 
	[user_field_1] varchar(8000) NULL, 
	[user_field_2] varchar(8000) NULL, 
	[company_code] varchar(8000) NULL, 
	[record_id] int NULL, 
	[last_updated_at] datetime2(6) NULL
);