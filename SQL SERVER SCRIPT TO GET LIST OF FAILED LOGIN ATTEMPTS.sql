DECLARE @TSQL  NVARCHAR(2000)
DECLARE @lC    INT

CREATE TABLE #TempLog (
      LogDate     DATETIME,
      ProcessInfo NVARCHAR(50),
      [Text] NVARCHAR(MAX))

CREATE TABLE #logF (
      ArchiveNumber     INT,
      LogDate           DATETIME,
      LogSize           INT
)

INSERT INTO #logF   
EXEC sp_enumerrorlogs
SELECT @lC = MIN(ArchiveNumber) FROM #logF
WHILE @lC IS NOT NULL
BEGIN
      INSERT INTO #TempLog
      EXEC sp_readerrorlog @lC
      SELECT @lC = MIN(ArchiveNumber) FROM #logF 
      WHERE ArchiveNumber > @lC
END

--Failed login counts. Useful for security audits.
SELECT Text,COUNT(Text) Number_Of_Attempts
FROM #TempLog where 
 Text like '%failed%' and ProcessInfo = 'LOGON'
 Group by Text
 ORDER BY Number_Of_Attempts DESC

 DROP TABLE #TempLog
 DROP TABLE #logF
