# Student records migration

At Talent and Careers, I migrated student records from Excel to SQL Server and built a Power BI student register. This portfolio demo recreates the workflow with synthetic records.

## Run the migration

Use SQL Server 2017 or later and a dedicated demo database. Open the CSV in Excel to inspect the source. The CSV represents the export from the legacy workbook.

1. Run `sql/01_create_tables.sql`.
2. Copy the CSV to a path readable by the SQL Server service. Run `sql/02_import_csv.sql` in SQLCMD mode with `CsvPath` set to that path, or pass it to sqlcmd with `-v CsvPath=...`.
3. Run `sql/03_migrate.sql`, then `tests/reconcile.sql`. Run both again to check that rerunning produces the same counts.

The expected result is 10 source rows, 5 students and 5 rejected or superseded rows. The highest valid source row wins for a repeated student ID. The register refreshes from a full snapshot in one transaction.

## Build the Power BI register

Import `demo.StudentRegister` from SQL Server as `StudentRegister`. Add the measures from `power-bi/measures.dax` individually. Use a table for student ID, name, course, enrolment date and status, with course and status slicers.

With slicers cleared, expect 5 students, 2 active, 2 completed and 1 withdrawn. Completion rate is 40%.
