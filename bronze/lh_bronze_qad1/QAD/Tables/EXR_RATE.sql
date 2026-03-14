CREATE TABLE [QAD].[EXR_RATE] (

	[EXR_CURR1] varchar(8000) NULL, 
	[EXR_CURR2] varchar(8000) NULL, 
	[EXR_START_DATE] datetime2(6) NULL, 
	[EXR_END_DATE] datetime2(6) NULL, 
	[EXR_RATE] decimal(38,18) NULL, 
	[EXR_RATE2] decimal(38,18) NULL, 
	[EXR_RATETYPE] varchar(8000) NULL, 
	[EXR_MOD_USERID] varchar(8000) NULL, 
	[EXR_MOD_DATE] datetime2(6) NULL, 
	[EXR_USER1] varchar(8000) NULL, 
	[EXR_USER2] varchar(8000) NULL, 
	[EXR__QADC01] varchar(8000) NULL, 
	[EXR__QADD01] decimal(38,18) NULL, 
	[EXR__QADL01] decimal(38,18) NULL, 
	[EXR__QADT01] datetime2(6) NULL, 
	[EXR_DOMAIN] varchar(8000) NULL, 
	[OID_EXR_RATE] decimal(38,18) NULL, 
	[PROGRESS_RECID] decimal(38,18) NULL
);