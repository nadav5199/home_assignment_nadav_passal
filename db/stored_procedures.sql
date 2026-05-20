USE TaskManagerDB;
GO

CREATE OR ALTER PROCEDURE usp_AssignTask
    @TaskID     INT,
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate task exists
        IF NOT EXISTS (SELECT 1 FROM Tasks WHERE TaskID = @TaskID)
            THROW 50001, 'Task not found.', 1;

        -- Validate employee exists
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
            THROW 50002, 'Employee not found.', 1;

        -- Validate task is not already Done
        IF EXISTS (SELECT 1 FROM Tasks WHERE TaskID = @TaskID AND Status = 'Done')
            THROW 50003, 'Cannot assign a task that is already Done.', 1;

        BEGIN TRANSACTION;

            UPDATE Tasks
            SET AssignedTo = @EmployeeID
            WHERE TaskID = @TaskID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
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

CREATE OR ALTER PROCEDURE usp_RebalanceTasks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE
            @EmployeeID  INT,
            @DeptID      INT,
            @OpenCount   INT,
            @TargetEmpID INT,
            @TaskToMove  INT,
            @Excess      INT;

        -- Cursor over every employee who currently has more than 3 open tasks
        DECLARE overloaded_cur CURSOR LOCAL FAST_FORWARD FOR
            SELECT e.EmployeeID, e.DepartmentID, COUNT(t.TaskID) AS OpenCount
            FROM Employees e
            JOIN Tasks t ON t.AssignedTo = e.EmployeeID
            WHERE t.Status IN ('Pending', 'In Progress')
            GROUP BY e.EmployeeID, e.DepartmentID
            HAVING COUNT(t.TaskID) > 3;

        OPEN overloaded_cur;
        FETCH NEXT FROM overloaded_cur INTO @EmployeeID, @DeptID, @OpenCount;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Excess = @OpenCount - 3;

            WHILE @Excess > 0
            BEGIN
                SET @TargetEmpID = NULL;
                SET @TaskToMove  = NULL;

                -- Least-loaded colleague in same department; ties broken by earliest EmployeeID
                SELECT TOP 1 @TargetEmpID = e.EmployeeID
                FROM Employees e
                WHERE e.DepartmentID = @DeptID
                  AND e.EmployeeID  <> @EmployeeID
                ORDER BY
                    (
                        SELECT COUNT(*)
                        FROM Tasks t2
                        WHERE t2.AssignedTo = e.EmployeeID
                          AND t2.Status IN ('Pending', 'In Progress')
                    ) ASC,
                    e.EmployeeID ASC;

                -- No available colleague in this department — stop redistributing for this employee
                IF @TargetEmpID IS NULL
                    BREAK;

                -- Pick the earliest task (by TaskID) to move
                SELECT TOP 1 @TaskToMove = TaskID
                FROM Tasks
                WHERE AssignedTo = @EmployeeID
                  AND Status IN ('Pending', 'In Progress')
                ORDER BY TaskID ASC;

                UPDATE Tasks
                SET AssignedTo = @TargetEmpID
                WHERE TaskID = @TaskToMove;

                SET @Excess = @Excess - 1;
            END

            FETCH NEXT FROM overloaded_cur INTO @EmployeeID, @DeptID, @OpenCount;
        END

        CLOSE overloaded_cur;
        DEALLOCATE overloaded_cur;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Clean up cursor if still open
        BEGIN TRY
            CLOSE overloaded_cur;
            DEALLOCATE overloaded_cur;
        END TRY
        BEGIN CATCH END CATCH;

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE usp_UpdateTaskStatus
    @TaskID    INT,
    @NewStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate task exists
        IF NOT EXISTS (SELECT 1 FROM Tasks WHERE TaskID = @TaskID)
            THROW 50001, 'Task not found.', 1;

        -- Validate the new status value
        IF @NewStatus NOT IN ('Pending', 'In Progress', 'Done')
            THROW 50004, 'Invalid status value. Allowed values: Pending, In Progress, Done.', 1;

        DECLARE @CurrentStatus NVARCHAR(20);
        SELECT @CurrentStatus = Status FROM Tasks WHERE TaskID = @TaskID;

        -- Enforce transition rules: Pending -> In Progress -> Done only
        IF NOT (
            (@CurrentStatus = 'Pending'     AND @NewStatus = 'In Progress') OR
            (@CurrentStatus = 'In Progress' AND @NewStatus = 'Done')
        )
        BEGIN
            THROW 50005, 'Invalid status transition. Allowed transitions: Pending -> In Progress -> Done.', 1;
        END

        UPDATE Tasks
        SET Status = @NewStatus
        WHERE TaskID = @TaskID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
