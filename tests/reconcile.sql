IF (SELECT COUNT(*) FROM demo.StudentStage) <> 10
    THROW 50010, 'Expected 10 source rows.', 1;
IF (SELECT COUNT(*) FROM demo.StudentRegister) <> 5
    THROW 50011, 'Expected 5 accepted students.', 1;
IF (SELECT COUNT(*) FROM demo.StudentReject) <> 5
    THROW 50012, 'Expected 5 rejected or superseded rows.', 1;
IF NOT EXISTS (SELECT 1 FROM demo.StudentRegister WHERE StudentID = 'S003' AND Status = 'COMPLETED')
    THROW 50013, 'Expected the latest valid S003 record.', 1;
SELECT Status, COUNT(*) AS Students FROM demo.StudentRegister GROUP BY Status ORDER BY Status;
SELECT Reason, COUNT(*) AS SourceRows FROM demo.StudentReject GROUP BY Reason ORDER BY Reason;
