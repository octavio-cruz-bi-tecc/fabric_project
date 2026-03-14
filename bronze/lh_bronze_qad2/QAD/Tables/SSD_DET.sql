CREATE TABLE [QAD].[SSD_DET] (

	[SSD_NETWORK] varchar(8000) NULL, 
	[SSD_REC_SITE] varchar(8000) NULL, 
	[SSD_SRC_SITE] varchar(8000) NULL, 
	[SSD_REF] varchar(8000) NULL, 
	[SSD_PERCENT] decimal(38,18) NULL, 
	[SSD_START] datetime2(6) NULL, 
	[SSD_END] datetime2(6) NULL, 
	[SSD_TRANS] varchar(8000) NULL, 
	[SSD_LEADTIME] decimal(38,18) NULL, 
	[SSD_USER1] varchar(8000) NULL, 
	[SSD_USER2] varchar(8000) NULL, 
	[SSD__QADD01] decimal(38,18) NULL, 
	[SSD__QADC01] varchar(8000) NULL, 
	[SSD_DOMAIN] varchar(8000) NULL, 
	[OID_SSD_DET] decimal(38,18) NULL, 
	[PROGRESS_RECID] decimal(38,18) NULL
);