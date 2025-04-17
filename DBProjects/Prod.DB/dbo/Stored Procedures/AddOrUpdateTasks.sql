CREATE PROCEDURE [dbo].[AddOrUpdateTasks]
    @EngagementID INT,
    @Tasks dbo.TaskType READONLY,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update existing tasks
    UPDATE target
    SET target.ModifiedBy = @ModUser, target.ModifiedOn = GETUTCDATE()
    FROM [dbo].[EngagementTaskMapping] AS target
    INNER JOIN @Tasks AS source
    ON target.EngagementID = @EngagementID AND target.TaskID = source.TaskID;

    -- Insert new tasks
    INSERT INTO [dbo].[EngagementTaskMapping] (EngagementID, TaskID, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    SELECT @EngagementID, source.TaskID, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE()
    FROM @Tasks AS source
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[EngagementTaskMapping] AS target WHERE target.EngagementID = @EngagementID AND target.TaskID = source.TaskID);

    -- Delete tasks not in the new list
    DELETE FROM [dbo].[EngagementTaskMapping]
    WHERE EngagementID = @EngagementID
    AND TaskID NOT IN (SELECT TaskID FROM @Tasks);
END;
