-- Place the CSV on the SQL Server host and pass the server-visible path as CsvPath.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
DELETE FROM demo.StudentStage;
BULK INSERT demo.StudentStage
FROM '$(CsvPath)'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', ROWTERMINATOR = '0x0a');
COMMIT;
