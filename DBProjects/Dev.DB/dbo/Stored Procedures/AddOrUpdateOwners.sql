CREATE PROCEDURE [dbo].[AddOrUpdateOwners]
    @EngagementID INT,
    @EngagementOwners dbo.EngagementOwnerType READONLY,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @EngagementTitle NVARCHAR(255),
            @ModUserName NVARCHAR(255),
            @Template NVARCHAR(255),
            @Description NVARCHAR(500),
            @NewUserID INT;

    -- Step 1: Get Engagement Title
    SELECT @EngagementTitle = Title FROM dbo.Engagements WHERE EngagementID = @EngagementID;

    -- Step 2: Get ModUser Name
    SELECT @ModUserName = DisplayName FROM dbo.Users WHERE UserID = @ModUser;

    -- Step 3: Get Notification Template
    SELECT @Template = Template FROM dbo.NotificationMaster WHERE NotificationID = 7;

    -- Step 4: Format Description
    SET @Description = CONCAT(@Template, '"', @EngagementTitle, '" by ', @ModUserName);

    -- Step 5: Update existing owners
    UPDATE target
    SET target.ModifiedBy = @ModUser, target.ModifiedOn = GETUTCDATE()
    FROM [dbo].[EngagementOwnersMapping] AS target
    INNER JOIN @EngagementOwners AS source
    ON target.EngagementID = @EngagementID AND target.UserID = source.UserID;

    -- Step 6: Insert new owners and capture UserIDs
	CREATE TABLE #InsertedUserIDs (UserID INT);
    INSERT INTO [dbo].[EngagementOwnersMapping] (EngagementID, UserID, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    OUTPUT inserted.UserID INTO #InsertedUserIDs
	SELECT @EngagementID, source.UserID, @ModUser, @ModUser, GETUTCDATE(), GETUTCDATE()
    FROM @EngagementOwners AS source
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[EngagementOwnersMapping] AS target WHERE target.EngagementID = @EngagementID AND target.UserID = source.UserID);

	-- Step 7: Loop through inserted UserIDs and send notifications
    WHILE EXISTS (SELECT TOP 1 UserID FROM #InsertedUserIDs)
    BEGIN
        SELECT TOP 1 @NewUserID = UserID FROM #InsertedUserIDs;

        -- Call CaptureNotification for each new team member
        EXEC [dbo].[CaptureNotification] @UserId = @NewUserID, @Description = @Description, @NotificationId = 7, @ModUser = @ModUser;

        -- Remove processed UserID from the table
        DELETE FROM #InsertedUserIDs WHERE UserID = @NewUserID;
    END

    -- Delete owners not in the new list
    DELETE FROM [dbo].[EngagementOwnersMapping]
    WHERE EngagementID = @EngagementID
    AND UserID NOT IN (SELECT UserID FROM @EngagementOwners);

	-- Clean up temporary table
    DROP TABLE #InsertedUserIDs;
END;
