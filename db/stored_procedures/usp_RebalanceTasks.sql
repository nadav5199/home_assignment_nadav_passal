USE TaskManagerDB;
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
