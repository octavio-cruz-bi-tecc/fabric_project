CREATE TABLE [dbo].[user_master] (

	[usr_firstname] varchar(8000) NULL, 
	[usr_ent_index] int NULL, 
	[usr_site_id] varchar(8000) NULL, 
	[usr_alias] varchar(8000) NULL, 
	[usr_pwd] varchar(8000) NULL, 
	[usr_name] varchar(8000) NULL, 
	[usr_lastname] varchar(8000) NULL, 
	[usr_process] varchar(8000) NULL, 
	[usr_site_index] int NULL, 
	[usr_sendmail] bit NULL, 
	[usr_area] varchar(8000) NULL, 
	[usr_emp_addr] varchar(8000) NULL, 
	[usr_isvalid] bit NULL, 
	[usr_isshared] bit NULL, 
	[usr_title_index] int NULL, 
	[usr_proc_index] int NULL, 
	[usr_cmmts] varchar(8000) NULL, 
	[usr_spnumber] varchar(8000) NULL, 
	[usr_group] varchar(8000) NULL, 
	[usr_index] int NULL, 
	[deposit_ts] datetime2(6) NULL
);