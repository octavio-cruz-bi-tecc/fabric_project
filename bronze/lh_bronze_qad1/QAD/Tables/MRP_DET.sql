CREATE TABLE [QAD].[MRP_DET] (

	[MRP_DATASET] varchar(8000) NULL, 
	[MRP_PART] varchar(8000) NULL, 
	[MRP_NBR] varchar(8000) NULL, 
	[MRP_LINE] varchar(8000) NULL, 
	[MRP_REL_DATE] datetime2(6) NULL, 
	[MRP_DUE_DATE] datetime2(6) NULL, 
	[MRP_QTY] decimal(38,18) NULL, 
	[MRP_TYPE] varchar(8000) NULL, 
	[MRP_DETAIL] varchar(8000) NULL, 
	[MRP__QAD01] decimal(38,18) NULL, 
	[MRP_SITE] varchar(8000) NULL, 
	[MRP_USER1] varchar(8000) NULL, 
	[MRP_USER2] varchar(8000) NULL, 
	[MRP_LINE2] varchar(8000) NULL, 
	[MRP_ORD_SITE] varchar(8000) NULL, 
	[MRP_KEYID] decimal(38,18) NULL, 
	[MRP_DOMAIN] varchar(8000) NULL, 
	[OID_MRP_DET] decimal(38,18) NULL, 
	[PROGRESS_RECID] decimal(38,18) NULL
);