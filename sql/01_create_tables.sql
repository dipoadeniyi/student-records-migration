IF SCHEMA_ID('demo') IS NULL EXEC('CREATE SCHEMA demo');

IF OBJECT_ID('demo.StudentStage', 'U') IS NULL
CREATE TABLE demo.StudentStage (
    SourceRow int NOT NULL PRIMARY KEY,
    StudentID nvarchar(50) NULL,
    FullName nvarchar(120) NULL,
    Course nvarchar(120) NULL,
    EnrolmentDate nvarchar(30) NULL,
    Status nvarchar(30) NULL
);

IF OBJECT_ID('demo.StudentRegister', 'U') IS NULL
CREATE TABLE demo.StudentRegister (
    StudentID nvarchar(50) NOT NULL PRIMARY KEY,
    FullName nvarchar(120) NOT NULL,
    Course nvarchar(120) NOT NULL,
    EnrolmentDate date NOT NULL,
    Status nvarchar(30) NOT NULL
);

IF OBJECT_ID('demo.StudentReject', 'U') IS NULL
CREATE TABLE demo.StudentReject (
    SourceRow int NOT NULL PRIMARY KEY,
    Reason nvarchar(100) NOT NULL
);
