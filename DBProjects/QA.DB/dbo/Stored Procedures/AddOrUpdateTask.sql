-- =============================================
-- Author:		<Kunal Mali>
-- Create date: <Create Date,,>
-- Description:	<This sp is used to add or update the custom tasks while adding or updating an engagement>
-- =============================================
CREATE PROCEDURE [dbo].[AddOrUpdateTask]
    @TaskID INT = NULL,
    @TaskName NVARCHAR(100),
    @TaskDescription NVARCHAR(255) = NULL,
    @IsDeleted BIT,
    @IsGeneric BIT,
    @ModUser INT,
    @NewTaskID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @TaskID IS NULL
    BEGIN
        -- Insert new task
        INSERT INTO EngagementTasks (TaskName, TaskDescription, IsDeleted, IsGeneric, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
        VALUES (@TaskName, @TaskDescription, @IsDeleted, @IsGeneric, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE());

        SET @NewTaskID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        -- Update existing task
        UPDATE EngagementTasks
        SET TaskName = @TaskName,
            TaskDescription = @TaskDescription,
            IsDeleted = @IsDeleted,
            IsGeneric = @IsGeneric,
            ModifiedBy = @ModUser,
            ModifiedOn = GETUTCDATE()
        WHERE TaskID = @TaskID;

        SET @NewTaskID = @TaskID;
    END
END;
