USE TaskManagerDB;
GO

CREATE OR ALTER PROCEDURE usp_GetAllTasks
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
            t.CreatedAt,
            e.FullName       AS AssignedToName,
            d.DepartmentName
        FROM      Tasks       t
        LEFT JOIN Employees   e ON e.EmployeeID   = t.AssignedTo
        LEFT JOIN Departments d ON d.DepartmentID = e.DepartmentID
        ORDER BY t.CreatedAt DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
