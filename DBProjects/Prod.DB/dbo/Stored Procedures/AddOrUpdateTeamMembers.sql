CREATE PROCEDURE [dbo].[AddOrUpdateTeamMembers]
    @EngagementID INT,
    @TeamMembers dbo.TeamMemberType READONLY,
    @ModUser INT
    
AS
BEGIN
    SET NOCOUNT ON;

    -- Update existing team members
    UPDATE target
    SET
        target.StartDate = source.StartDate,
        target.EndDate = source.EndDate,
        target.MaxWeeklyHours = source.MaxWeeklyHours,
        target.ModifiedBy = @ModUser,
        target.ModifiedOn = GETUTCDATE()
    FROM [dbo].[EngagementUserMapping] AS target
    INNER JOIN @TeamMembers AS source
    ON target.EngagementID = @EngagementID AND target.UserID = source.UserID;

    -- Insert new team members
    INSERT INTO [dbo].[EngagementUserMapping] (EngagementID, UserID, StartDate, EndDate, MaxWeeklyHours, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    SELECT @EngagementID, source.UserID, source.StartDate, source.EndDate, source.MaxWeeklyHours, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE()
    FROM @TeamMembers AS source
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[EngagementUserMapping] AS target WHERE target.EngagementID = @EngagementID AND target.UserID = source.UserID);

    -- Delete team members not in the new list
    DELETE FROM [dbo].[EngagementUserMapping]
    WHERE EngagementID = @EngagementID
    AND UserID NOT IN (SELECT UserID FROM @TeamMembers);
END;
