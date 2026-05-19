USE TaskManagerDB;
GO

CREATE OR ALTER PROCEDURE usp_GetOverdueTasks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            t.TaskID,
            t.Title,
            t.Description,
            t.Status,
            t.DueDate,
            e.FullName       AS AssignedToName,
            d.DepartmentName
        FROM      Tasks       t
        LEFT JOIN Employees   e ON e.EmployeeID   = t.AssignedTo
        LEFT JOIN Departments d ON d.DepartmentID = e.DepartmentID
        WHERE t.DueDate < CAST(GETDATE() AS DATE)
          AND t.Status  != 'Done'
        ORDER BY t.DueDate ASC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
