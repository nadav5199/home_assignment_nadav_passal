USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TaskManagerDB')
    EXEC('CREATE DATABASE TaskManagerDB');
GO

-- Ensure compatibility level supports THROW and other modern T-SQL features
ALTER DATABASE TaskManagerDB SET COMPATIBILITY_LEVEL = 130;
GO

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

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees')
BEGIN
    CREATE TABLE Employees (
        EmployeeID   INT           NOT NULL IDENTITY(1,1),
        FullName     NVARCHAR(150) NOT NULL,
        Email        NVARCHAR(255) NOT NULL,
        DepartmentID INT           NOT NULL,
        CreatedAt    DATETIME2     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID),
        CONSTRAINT UQ_Employees_Email UNIQUE (Email),
        CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentID)
            REFERENCES Departments(DepartmentID)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tasks')
BEGIN
    CREATE TABLE Tasks (
        TaskID      INT           NOT NULL IDENTITY(1,1),
        Title       NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        AssignedTo  INT           NULL,
        Status      NVARCHAR(20)  NOT NULL DEFAULT 'Pending',
        DueDate     DATE          NOT NULL,
        CreatedAt   DATETIME2     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Tasks PRIMARY KEY (TaskID),
        CONSTRAINT FK_Tasks_Employee FOREIGN KEY (AssignedTo)
            REFERENCES Employees(EmployeeID),
        CONSTRAINT CK_Tasks_Status CHECK (Status IN ('Pending', 'In Progress', 'Done'))
    );
END
GO
