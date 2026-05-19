USE TaskManagerDB;
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
