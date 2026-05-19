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
