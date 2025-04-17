CREATE PROCEDURE [dbo].[AddOrUpdateOwners]
    @EngagementID INT,
    @EngagementOwners dbo.EngagementOwnerType READONLY,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update existing owners
    UPDATE target
    SET target.ModifiedBy = @ModUser, target.ModifiedOn = GETUTCDATE()
    FROM [dbo].[EngagementOwnersMapping] AS target
    INNER JOIN @EngagementOwners AS source
    ON target.EngagementID = @EngagementID AND target.UserID = source.UserID;

    -- Insert new owners
    INSERT INTO [dbo].[EngagementOwnersMapping] (EngagementID, UserID, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    SELECT @EngagementID, source.UserID, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE()
    FROM @EngagementOwners AS source
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[EngagementOwnersMapping] AS target WHERE target.EngagementID = @EngagementID AND target.UserID = source.UserID);

    -- Delete owners not in the new list
    DELETE FROM [dbo].[EngagementOwnersMapping]
    WHERE EngagementID = @EngagementID
    AND UserID NOT IN (SELECT UserID FROM @EngagementOwners);
END;
