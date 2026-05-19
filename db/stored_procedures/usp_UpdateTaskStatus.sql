USE TaskManagerDB;
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
