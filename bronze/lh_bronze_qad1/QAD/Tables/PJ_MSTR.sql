CREATE TABLE [QAD].[PJ_MSTR] (

	[PJ_PROJECT] varchar(8000) NULL, 
	[PJ_DESC] varchar(8000) NULL, 
	[PJ_ACTIVE] decimal(38,18) NULL, 
	[PJ_BEG_DT] datetime2(6) NULL, 
	[PJ_CMTINDX] decimal(38,18) NULL, 
	[PJ_COMP] datetime2(6) NULL, 
	[PJ_FINDATE] datetime2(6) NULL, 
	[PJ_REVDATE] datetime2(6) NULL, 
	[PJ_REVFIN] datetime2(6) NULL, 
	[PJ_STAT] varchar(8000) NULL, 
	[PJ_TYPE] varchar(8000) NULL, 
	[PJ_USER1] varchar(8000) NULL, 
	[PJ_USER2] varchar(8000) NULL, 
	[PJ__QADC01] varchar(8000) NULL, 
	[PJ_DOMAIN] varchar(8000) NULL, 
	[OID_PJ_MSTR] decimal(38,18) NULL, 
	[PROGRESS_RECID] decimal(38,18) NULL
);