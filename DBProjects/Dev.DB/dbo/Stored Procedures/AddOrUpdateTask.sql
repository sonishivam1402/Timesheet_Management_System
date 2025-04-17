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

	IF EXISTS (
    SELECT 1
    FROM EngagementTasks
    WHERE UPPER(TRIM(TaskName)) = UPPER(TRIM(@TaskName))
      AND IsDeleted = 0
      AND (@TaskID IS NULL OR TaskID != @TaskID)
	)
	BEGIN
		SET @NewTaskID = -1;
		RETURN;
	END

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