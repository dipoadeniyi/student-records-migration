SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF NOT EXISTS (SELECT 1 FROM demo.StudentStage)
    THROW 50001, 'Staging is empty. Import the workbook export first.', 1;

WITH Normalised AS (
    SELECT SourceRow, NULLIF(TRIM(StudentID), '') AS StudentID,
           NULLIF(TRIM(FullName), '') AS FullName, NULLIF(TRIM(Course), '') AS Course,
           TRY_CONVERT(date, EnrolmentDate, 23) AS EnrolmentDate,
           UPPER(TRIM(REPLACE(Status, CHAR(13), ''))) AS Status
    FROM demo.StudentStage
), Validated AS (
    SELECT n.*,
           CASE WHEN StudentID IS NULL THEN 'Missing student ID'
                WHEN FullName IS NULL THEN 'Missing name'
                WHEN Course IS NULL THEN 'Missing course'
                WHEN EnrolmentDate IS NULL THEN 'Invalid enrolment date'
                WHEN Status IS NULL OR Status NOT IN ('ACTIVE', 'COMPLETED', 'WITHDRAWN')
                    THEN 'Invalid status'
           END AS InvalidReason
    FROM Normalised n
), Ranked AS (
    SELECT v.*,
           ROW_NUMBER() OVER (
               PARTITION BY StudentID
               ORDER BY CASE WHEN InvalidReason IS NULL THEN 0 ELSE 1 END, SourceRow DESC
           ) AS RowRank
    FROM Validated v
)
SELECT SourceRow, StudentID, FullName, Course, EnrolmentDate, Status,
       COALESCE(InvalidReason, CASE WHEN RowRank > 1 THEN 'Superseded source row' END) AS RejectReason
INTO #Classified
FROM Ranked;

-- Refresh a dedicated demo register from the full snapshot in one transaction.
DELETE FROM demo.StudentReject;
DELETE FROM demo.StudentRegister;
INSERT demo.StudentRegister (StudentID, FullName, Course, EnrolmentDate, Status)
SELECT StudentID, FullName, Course, EnrolmentDate, Status
FROM #Classified WHERE RejectReason IS NULL;
INSERT demo.StudentReject (SourceRow, Reason)
SELECT SourceRow, RejectReason FROM #Classified WHERE RejectReason IS NOT NULL;

IF (SELECT COUNT(*) FROM demo.StudentStage) <>
   (SELECT COUNT(*) FROM demo.StudentRegister) + (SELECT COUNT(*) FROM demo.StudentReject)
    THROW 50002, 'Source counts do not reconcile to accepted and rejected rows.', 1;

DROP TABLE #Classified;
COMMIT;
