
-----Script to determnine level of Fragementation-----

SELECT S.name as 'Schema',
T.name as 'Table',
I.name as 'Index',
DDIPS.avg_fragmentation_in_percent,
DDIPS.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
INNER JOIN sys.schemas S on T.schema_id = S.schema_id
INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
and I.name is not null
AND DDIPS.avg_fragmentation_in_percent > 0
and page_count >= 1000
ORDER BY DDIPS.avg_fragmentation_in_percent desc

------------------------------------------------------------------------------


----Code for missing Clustered Indexes run it against the database---

SELECT
t.name AS TableName
FROM
    sys.tables t
WHERE
    t.object_id NOT IN (
        SELECT
            i.object_id
        FROM
            sys.indexes i
        WHERE
            i.index_id = 1 -- 1 is the index_id for clustered indexes
    )
ORDER BY
    TableName;


---------------------------------------------------------------------------------



---- Query to find missing indexes and generate CREATE INDEX statements-----
SELECT
    migs.avg_user_impact AS AvgUserImpact,
    migs.user_seeks AS UserSeeks,
    mid.statement AS TableName,
    QUOTENAME(mid.statement) + '.' + QUOTENAME(mid.equality_columns) +
        CASE WHEN mid.included_columns IS NOT NULL THEN
            '(' + QUOTENAME(mid.included_columns) + ')'
        ELSE
            ''
        END AS CreateIndexStatement
FROM
    sys.dm_db_missing_index_groups mig
INNER JOIN
    sys.dm_db_missing_index_group_stats migs
    ON mig.index_group_handle = migs.group_handle
INNER JOIN
    sys.dm_db_missing_index_details mid
    ON mig.index_handle = mid.index_handle
ORDER BY
    migs.avg_user_impact DESC;




-----------------------------------------------------------------------------------------




-----Script to rebuild non-clustered index (Change parameters)----

	USE [AdeptSchema]
GO
ALTER INDEX [fm100apipr_S_PLUGINID_ind] ON [dbo].[fm100apipr] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO



------Francis Code to Join table-----
CREATE CLUSTERED INDEX IX_CertificateID
    ON dbo.CertificateColors (CertificateID);   
GO


---To see Table missing Index and their column Types------------

select a.name AS 'table name',b.name AS 'column name',b.colID AS 'column ID/ORDER', c.name AS 'column type'
from sysobjects a
join syscolumns b on a.ID = b.ID
join systypes c on b.xtype = c.xtype
order by a.name,b.colID 

select * from systypes
select * from syscolumns
select * from sysindexes


------------------------------------------

--
select distinct a.name AS 'table name',a.xtype,i.indid--,b.name AS 'column name',b.colID AS 'column ID/ORDER', c.name AS 'column type'
from sysobjects a
join syscolumns b on a.ID = b.ID
join systypes c on b.xtype = c.xtype
full join sysindexes i on i.id = a.id
--where a.name = 'CertificateColors'
WHERE 
a.xtype = 'U'
and i.id not in (select d.id from sysindexes d where d.indid = 1)
/*and (a.id NOT IN (
        SELECT
            i.id
        FROM
            sysindexes i
        WHERE
            i.indid = 1 -- 1 is the index_id for clustered indexes
   ))*/

order by a.name--,b.colID 


------------------------------------------------------------------------------------------------------------------------




CREATE CLUSTERED INDEX CIDX_CertificateColors_CertificateID
ON dbo.CertificateColors (Certificateid);   
GO

-------------------------------------------------------------------------------------------------------


----Script to create clustered Index--
  
CREATE CLUSTERED INDEX IX_TestTable_TestCol1   
    ON dbo.TestTable (TestCol1);   
GO

(2) ----code to created clusted index----chatgpt----

-- Syntax
CREATE CLUSTERED INDEX index_name
ON table_name (column1, column2, ...);


-------------------------------------------------------------------------------------------------------



----Select specify column in table and filter with where clause----
select ChangeOrderId, Description,CreatedDate from [bck].[ChangeOrder]
where [CreatedDate] = '2014-03-13 18:12:55.6566667'


--------------------------------------------------------------------------------------------------------


----To choose exact column you want to see in a Table----

Select * from customer
From oder
Where custimerID>80

---------------------------------------------------------------------------------------------------------

----Code to create cluster index Against Table---vi
SELECT
    migs.last_user_seek,
    mid.[statement] AS [Database.Schema.Table],
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.unique_compiles,
    migs.user_seeks,
    migs.avg_total_user_cost,
    migs.avg_user_impact
FROM
    sys.dm_db_missing_index_groups AS mig
INNER JOIN sys.dm_db_missing_index_group_stats AS migs
    ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid
    ON mig.index_handle = mid.index_handle
ORDER BY
    migs.avg_user_impact DESC;



	------------------------------------------------------------------------------------------------------------

---Code to show result set containing in a production.product table----

SELECT
    ProductID,
    Name,
    ListPrice,
    StandardCost
FROM
    Production.Product;


------------------------------------------------------------------------------------------------------------------------

----Code to create clustered index against Instance-------
SELECT
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.object_id = i.object_id
WHERE
    i.index_id < 2
    AND i.type_desc = 'CLUSTERED';



-------------------------------------------------------------------------------------------------------------------


----Code to check DB in restoring Mode-----
Commence the last line out is no result shows at first---(Where r.command.....)

 ---
 

 

SELECT r.command                                                                     AS 'Command',
       s.[text]                                                                      AS 'Command Text',
       CONVERT(VARCHAR,r.start_time)                                                 AS 'Start Date-Time',
       r.Percent_Complete                                                            AS 'Percent Complete', 
 
       CAST(((DATEDIFF(s,start_time,GETDATE()))/3600) AS VARCHAR) + ' hour(s), '
     + CAST((DATEDIFF(s,start_time,GETDATE())%3600)/60 AS VARCHAR) + 'min, '
     + CAST((DATEDIFF(s,start_time,GETDATE())%60) AS VARCHAR) + ' sec'               AS 'Running Time',
 
       CAST((r.estimated_completion_time/3600000) AS VARCHAR) + ' hour(s), '
     + CAST((r.estimated_completion_time %3600000)/60000 AS VARCHAR) + 'min, '
     + CAST((r.estimated_completion_time %60000)/1000 AS VARCHAR) + ' sec'           AS 'Est_Time_To_Go',
 
       CONVERT(VARCHAR,DATEADD(SECOND,r.estimated_completion_time/1000, GETDATE()))  AS 'Est_Completion_DateTime' 

FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.[sql_handle]) s

WHERE r.command in ('RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'BACKUP LOG')

--------------------------------------

SELECT wait_resource,logical_reads,reads,writes,  A.NAME,B.TOTAL_ELAPSED_TIME/60000 AS [Running Time],

B.ESTIMATED_COMPLETION_TIME/60000 AS [Remaining],

B.PERCENT_COMPLETE as [%],*,(SELECT TEXT FROM sys.dm_exec_sql_text(B.SQL_HANDLE))AS COMMAND FROM

MASTER..SYSDATABASES A, sys.dm_exec_requests B

WHERE A.DBID=B.DATABASE_ID AND B.COMMAND LIKE '%restore%'

order by percent_complete desc,B.TOTAL_ELAPSED_TIME/60000 desc


-- Read more: http://www.sqldbadiaries.com/2010/09/07/get-backup-status-in-sql-server-2005-2008/#ixzz2wzOHIfzX


------------------------------------------------------------------------------------------------------------------------
------Code for Alerts---------------
email address: SQLAdmin@phl.org

Server Name: smartmail.phl.org



set quoted_identifier off
select "EXEC msdb.dbo.sp_add_notification @alert_name=N'"+name+"', @operator_name=N'SQLAdmin', @notification_method = 1;"
from sysalerts


-----------------------------------------------------------


---------Job Names Codes-------------

set quoted_identifier off
select "EXEC msdb.dbo.sp_update_job @job_name=N'"+name+"', @notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'SQLAdmin';"
		From sysjobs





USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_id=N'14e6ccfd-a3b8-45b7-9706-f989bb0bd8df', 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'SQLAdmin'
GO


SELECT * FROM sysjobs


set quoted_identifier off
select "EXEC msdb.dbo.sp_update_job @job_name=N'"+name+"', @notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'SQLAdmin';"
		From sysjobs


----JOBs-----

USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_id=N'14e6ccfd-a3b8-45b7-9706-f989bb0bd8df', 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'SQLAdmin'
GO


SELECT * FROM sysjobs


set quoted_identifier off
select "EXEC msdb.dbo.sp_update_job @job_name=N'"+name+"', @notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name=N'SQLAdmin';"
		From sysjobs


----------script to fix threshold issues in Logshipping------------
	
	EXEC master.dbo.sp_change_log_shipping_secondary_database         
   @secondary_database = 'QCDBexec',
   @restore_threshold = 60



---------To Get a File Location of a Database----------------------------------

  Expand Database
  Expand System Database
  Expand Msdb
  Expand Tables
  expand Systems Tables
  select * from [dbo].[log_shipping_primary_databases] and search till You find it.

---------------------------------------------------------------------------------------------------------

----------Script to find anything about blocking---------------

WITH cteHead ( session_id,request_id,wait_type,wait_resource,last_wait_type,is_user_process,request_cpu_time
,request_logical_reads,request_reads,request_writes,wait_time,blocking_session_id,memory_usage
,session_cpu_time,session_reads,session_writes,session_logical_reads
,percent_complete,est_completion_time,request_start_time,request_status,command
,plan_handle,sql_handle,statement_start_offset,statement_end_offset,most_recent_sql_handle
,session_status,group_id,query_hash,query_plan_hash) 
AS ( SELECT sess.session_id, req.request_id, LEFT (ISNULL (req.wait_type, ''), 50) AS 'wait_type'
    , LEFT (ISNULL (req.wait_resource, ''), 40) AS 'wait_resource', LEFT (req.last_wait_type, 50) AS 'last_wait_type'
    , sess.is_user_process, req.cpu_time AS 'request_cpu_time', req.logical_reads AS 'request_logical_reads'
    , req.reads AS 'request_reads', req.writes AS 'request_writes', req.wait_time, req.blocking_session_id,sess.memory_usage
    , sess.cpu_time AS 'session_cpu_time', sess.reads AS 'session_reads', sess.writes AS 'session_writes', sess.logical_reads AS 'session_logical_reads'
    , CONVERT (decimal(5,2), req.percent_complete) AS 'percent_complete', req.estimated_completion_time AS 'est_completion_time'
    , req.start_time AS 'request_start_time', LEFT (req.status, 15) AS 'request_status', req.command
    , req.plan_handle, req.[sql_handle], req.statement_start_offset, req.statement_end_offset, conn.most_recent_sql_handle
    , LEFT (sess.status, 15) AS 'session_status', sess.group_id, req.query_hash, req.query_plan_hash
    FROM sys.dm_exec_sessions AS sess
    LEFT OUTER JOIN sys.dm_exec_requests AS req ON sess.session_id = req.session_id
    LEFT OUTER JOIN sys.dm_exec_connections AS conn on conn.session_id = sess.session_id 
    )
, cteBlockingHierarchy (head_blocker_session_id, session_id, blocking_session_id, wait_type, wait_duration_ms,
wait_resource, statement_start_offset, statement_end_offset, plan_handle, sql_handle, most_recent_sql_handle, [Level])
AS ( SELECT head.session_id AS head_blocker_session_id, head.session_id AS session_id, head.blocking_session_id
    , head.wait_type, head.wait_time, head.wait_resource, head.statement_start_offset, head.statement_end_offset
    , head.plan_handle, head.sql_handle, head.most_recent_sql_handle, 0 AS [Level]
    FROM cteHead AS head
    WHERE (head.blocking_session_id IS NULL OR head.blocking_session_id = 0)
    AND head.session_id IN (SELECT DISTINCT blocking_session_id FROM cteHead WHERE blocking_session_id != 0)
    UNION ALL
    SELECT h.head_blocker_session_id, blocked.session_id, blocked.blocking_session_id, blocked.wait_type,
    blocked.wait_time, blocked.wait_resource, h.statement_start_offset, h.statement_end_offset,
    h.plan_handle, h.sql_handle, h.most_recent_sql_handle, [Level] + 1
    FROM cteHead AS blocked
    INNER JOIN cteBlockingHierarchy AS h ON h.session_id = blocked.blocking_session_id and h.session_id!=blocked.session_id --avoid infinite recursion for latch type of blocking
    WHERE h.wait_type COLLATE Latin1_General_BIN NOT IN ('EXCHANGE', 'CXPACKET') or h.wait_type is null
    )
SELECT bh.*, txt.text AS blocker_query_or_most_recent_query 
FROM cteBlockingHierarchy AS bh 
OUTER APPLY sys.dm_exec_sql_text (ISNULL ([sql_handle], most_recent_sql_handle)) AS txt;
