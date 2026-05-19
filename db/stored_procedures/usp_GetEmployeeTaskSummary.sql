USE TaskManagerDB;
GO

CREATE OR ALTER PROCEDURE usp_GetEmployeeTaskSummary
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            e.EmployeeID,
            e.FullName,
            d.DepartmentName,
            COUNT(t.TaskID)                                                    AS TotalTasks,
            SUM(CASE WHEN t.Status = 'Pending'     THEN 1 ELSE 0 END)         AS PendingTasks,
            SUM(CASE WHEN t.Status = 'In Progress' THEN 1 ELSE 0 END)         AS InProgressTasks,
            SUM(CASE WHEN t.Status = 'Done'        THEN 1 ELSE 0 END)         AS DoneTasks,
            nd.Title                                                           AS NearestDueTaskTitle,
            nd.DueDate                                                         AS NearestDueDate
        FROM Employees e
        JOIN  Departments d ON d.DepartmentID = e.DepartmentID
        LEFT JOIN Tasks  t ON t.AssignedTo    = e.EmployeeID
        OUTER APPLY (
            SELECT TOP 1 t2.Title, t2.DueDate
            FROM Tasks t2
            WHERE t2.AssignedTo = e.EmployeeID
              AND t2.Status    != 'Done'
              AND t2.DueDate   >= CAST(GETDATE() AS DATE)
            ORDER BY t2.DueDate ASC
        ) nd
        GROUP BY
            e.EmployeeID,
            e.FullName,
            d.DepartmentName,
            nd.Title,
            nd.DueDate;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
