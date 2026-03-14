CREATE TABLE [dbo].[maintenance_log] (

	[control_source] varchar(8000) NULL, 
	[order_in_source] int NULL, 
	[table] varchar(8000) NULL, 
	[task_id] int NULL, 
	[optimize_enabled] bit NULL, 
	[vacuum_enabled] bit NULL, 
	[zorder_cols] varchar(8000) NULL, 
	[retain_hours] int NULL, 
	[exists] bit NULL, 
	[is_delta] bit NULL, 
	[optimize_status] varchar(8000) NULL, 
	[vacuum_status] varchar(8000) NULL, 
	[optimize_seconds] float NULL, 
	[vacuum_seconds] float NULL, 
	[error] varchar(8000) NULL, 
	[run_utc] datetime2(6) NULL
);