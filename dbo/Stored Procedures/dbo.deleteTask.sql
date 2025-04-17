USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[DeleteTask]    Script Date: 17-12-2024 17:50:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DeleteTask]
    @TaskId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @canDelete BIT;

    -- Check if the task can be deleted
    SET @canDelete = dbo.fnCanDeleteTask(@TaskId, @UserId);

    -- If deletion is allowed
    IF @canDelete = 1
    BEGIN
        DELETE FROM TimesheetLines WHERE TaskId = @TaskId;
        BEGIN TRY
            BEGIN TRANSACTION;

            -- Delete from related tables
            DELETE FROM EngagementTaskMapping WHERE TaskId = @TaskId;
			UPDATE dbo.EngagementTasks SET IsDeleted = 1 WHERE TaskID = @TaskID
            COMMIT TRANSACTION;

            SELECT 
                CAST(1 AS BIT) AS CanDelete, 
                'Task deleted successfully.' AS Message;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;

            SELECT 
                CAST(0 AS BIT) AS CanDelete, 
                'An error occurred while deleting the task.' AS Message;
        END CATCH;
    END
    ELSE
		BEGIN
            SELECT 
                CAST(0 AS BIT) AS CanDelete, 
                'Tasks already in use' AS Message;
        END
END;
GO


