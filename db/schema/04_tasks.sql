USE TaskManagerDB;
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
