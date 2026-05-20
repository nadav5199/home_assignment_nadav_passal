USE TaskManagerDB;
GO

-- Clear in reverse FK order
DELETE FROM Tasks;
DELETE FROM Employees;
DELETE FROM Departments;

DBCC CHECKIDENT ('Tasks',       RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Employees',   RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Departments', RESEED, 0) WITH NO_INFOMSGS;
GO

-- Departments
INSERT INTO Departments (DepartmentName) VALUES
    ('Engineering'),
    ('Marketing'),
    ('HR');
GO

-- Employees — look up department IDs by name so we never rely on hardcoded values
DECLARE
    @EngID INT = (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'Engineering'),
    @MktID INT = (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'Marketing'),
    @HRID  INT = (SELECT DepartmentID FROM Departments WHERE DepartmentName = 'HR');

INSERT INTO Employees (FullName, Email, DepartmentID) VALUES
    ('Alice Johnson', 'alice.johnson@company.com', @EngID),
    ('Bob Smith',     'bob.smith@company.com',     @EngID),
    ('Carol White',   'carol.white@company.com',   @MktID),
    ('David Brown',   'david.brown@company.com',   @MktID),
    ('Eve Davis',     'eve.davis@company.com',      @HRID),
    ('Frank Miller',  'frank.miller@company.com',   @HRID);
GO

-- Tasks — look up employee IDs by email so we never rely on hardcoded values
-- Alice (Engineering) gets 4 open tasks — useful for testing usp_RebalanceTasks
DECLARE
    @AliceID INT = (SELECT EmployeeID FROM Employees WHERE Email = 'alice.johnson@company.com'),
    @BobID   INT = (SELECT EmployeeID FROM Employees WHERE Email = 'bob.smith@company.com'),
    @CarolID INT = (SELECT EmployeeID FROM Employees WHERE Email = 'carol.white@company.com'),
    @DavidID INT = (SELECT EmployeeID FROM Employees WHERE Email = 'david.brown@company.com'),
    @EveID   INT = (SELECT EmployeeID FROM Employees WHERE Email = 'eve.davis@company.com'),
    @FrankID INT = (SELECT EmployeeID FROM Employees WHERE Email = 'frank.miller@company.com');

INSERT INTO Tasks (Title, Description, AssignedTo, Status, DueDate) VALUES
    -- Alice — 4 open tasks (1 overdue)
    ('Build login page',
     'Implement the employee login screen with form validation.',
     @AliceID, 'Pending',     CAST(DATEADD(DAY,  14, GETDATE()) AS DATE)),

    ('Fix critical API bug',
     'Resolve the null-reference exception in the /tasks endpoint.',
     @AliceID, 'In Progress', CAST(DATEADD(DAY,  -2, GETDATE()) AS DATE)),  -- OVERDUE

    ('Code review — Sprint 5',
     'Review pull requests opened during sprint 5.',
     @AliceID, 'Pending',     CAST(DATEADD(DAY,   7, GETDATE()) AS DATE)),

    ('Database schema migration',
     'Migrate legacy schema to the new TaskManagerDB structure.',
     @AliceID, 'Pending',     CAST(DATEADD(DAY,  21, GETDATE()) AS DATE)),

    -- Bob — 1 open, 1 done
    ('Write unit tests',
     'Add unit tests for the task assignment service.',
     @BobID, 'Pending',       CAST(DATEADD(DAY,  14, GETDATE()) AS DATE)),

    ('Deploy to staging',
     'Push the latest build to the staging environment.',
     @BobID, 'Done',          CAST(DATEADD(DAY,  -7, GETDATE()) AS DATE)),

    -- Carol — 2 open (1 overdue)
    ('Create Q2 email campaign',
     'Draft and schedule the Q2 promotional email campaign.',
     @CarolID, 'Pending',     CAST(DATEADD(DAY,  -3, GETDATE()) AS DATE)),  -- OVERDUE

    ('Design monthly newsletter',
     'Design the layout and content for the May company newsletter.',
     @CarolID, 'In Progress', CAST(DATEADD(DAY,  10, GETDATE()) AS DATE)),

    -- David — 1 open
    ('Analyse customer survey results',
     'Process and summarise Q1 customer satisfaction survey data.',
     @DavidID, 'Pending',     CAST(DATEADD(DAY,  30, GETDATE()) AS DATE)),

    -- Eve — 2 open (1 overdue)
    ('Update HR handbook',
     'Revise the HR handbook to reflect the new remote-work policy.',
     @EveID, 'In Progress',   CAST(DATEADD(DAY,  -5, GETDATE()) AS DATE)),  -- OVERDUE

    ('Conduct Q2 interviews',
     'Schedule and run interviews for the three open engineering roles.',
     @EveID, 'Pending',       CAST(DATEADD(DAY,   9, GETDATE()) AS DATE)),

    -- Frank — 1 open (overdue), 1 done
    ('Onboard new hire',
     'Complete the onboarding checklist for the new junior developer.',
     @FrankID, 'Pending',     CAST(DATEADD(DAY,  -8, GETDATE()) AS DATE)),  -- OVERDUE

    ('Process Q1 payroll',
     'Run and verify the Q1 payroll batch.',
     @FrankID, 'Done',        CAST(DATEADD(DAY, -60, GETDATE()) AS DATE));
GO

-- Sanity check
SELECT 'Departments' AS [Table], COUNT(*) AS [Rows] FROM Departments
UNION ALL
SELECT 'Employees',              COUNT(*)             FROM Employees
UNION ALL
SELECT 'Tasks',                  COUNT(*)             FROM Tasks;
GO
