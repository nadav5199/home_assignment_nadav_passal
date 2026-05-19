USE TaskManagerDB;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Departments')
BEGIN
    CREATE TABLE Departments (
        DepartmentID   INT           NOT NULL IDENTITY(1,1),
        DepartmentName NVARCHAR(100) NOT NULL,
        CONSTRAINT PK_Departments PRIMARY KEY (DepartmentID),
        CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName)
    );
END
GO
