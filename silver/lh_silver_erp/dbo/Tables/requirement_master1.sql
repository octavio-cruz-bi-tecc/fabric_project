CREATE TABLE [dbo].[requirement_master1] (

	[req_status] int NULL, 
	[req_ser_index] int NULL, 
	[req_faq] bit NULL, 
	[req_desc] varchar(8000) NULL, 
	[req_date] datetime2(6) NULL, 
	[req_priority] int NULL, 
	[req_is_visible] bit NULL, 
	[req_mod_st] bit NULL, 
	[req_ent_index] int NULL, 
	[req_usr_index] int NULL, 
	[req_index] int NULL, 
	[req_delete] bit NULL, 
	[req_global] bit NULL, 
	[deposit_ts] datetime2(6) NULL
);