CREATE TABLE [dbo].[services_master1] (

	[ser_index] int NULL, 
	[ser_esad_index] int NULL, 
	[ser_duedays] int NULL, 
	[ser_proj_index] int NULL, 
	[ser_valid] bit NULL, 
	[ser_Key_words] varchar(8000) NULL, 
	[ser_global] bit NULL, 
	[ser_delete] bit NULL, 
	[ser_type_index] int NULL, 
	[ser_name] varchar(8000) NULL, 
	[ser_duehrs] int NULL, 
	[ser_client_close] bit NULL, 
	[ser_description] varchar(8000) NULL, 
	[ser_ent_index] int NULL, 
	[ser_emerg_mail] varchar(8000) NULL, 
	[deposit_ts] datetime2(6) NULL
);