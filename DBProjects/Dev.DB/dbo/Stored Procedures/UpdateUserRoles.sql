



CREATE PROCEDURE [dbo].[UpdateUserRoles]
    @NewRoles VARCHAR(200),
    @UserId INT,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @Template NVARCHAR(255),
            @RoleName NVARCHAR(255),
            @Description NVARCHAR(500);

    -- Get the notification template
    SELECT @Template = Template FROM dbo.NotificationMaster WHERE NotificationID = 4;

    -- Hold all the roles received in a table variable
    DECLARE @tblRoles TABLE (RoleId INT);
    INSERT INTO @tblRoles(RoleId)
    SELECT value FROM STRING_SPLIT(@NewRoles, ',')
    WHERE ISNUMERIC(value) = 1;

    -- Delete roles that are no longer assigned
    DELETE FROM [dbo].[UserRolesMapping]
    WHERE UserId = @UserId
    AND RoleId NOT IN (SELECT RoleId FROM @tblRoles);

    -- Insert new roles and capture only the new RoleIDs for notifications
    DECLARE @NewlyInsertedRoles TABLE (RoleId INT);
    INSERT INTO [dbo].[UserRolesMapping] (UserID, RoleID, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn)
    OUTPUT inserted.RoleID INTO @NewlyInsertedRoles -- Capture only newly inserted roles
    SELECT @UserId, RoleId, @ModUser, GETUTCDATE(), @ModUser, GETUTCDATE()
    FROM @tblRoles
    WHERE RoleId NOT IN (SELECT RoleId FROM [dbo].[UserRolesMapping] WHERE UserId = @UserId);

    -- Loop through newly inserted roles and capture notifications
    DECLARE @NewRoleID INT;

    WHILE EXISTS (SELECT TOP 1 RoleId FROM @NewlyInsertedRoles)
    BEGIN
        SELECT TOP 1 @NewRoleID = RoleId FROM @NewlyInsertedRoles;

        -- Get the role name
        SELECT @RoleName = RoleName FROM dbo.RolesMaster WHERE RoleID = @NewRoleID;

        -- Format the description
        SET @Description = CONCAT(@Template, @RoleName);

        -- Call CaptureNotification for each newly added role
        EXEC [dbo].[CaptureNotification] @UserId = @UserId, @Description = @Description, @NotificationId = 4, @ModUser = @ModUser;

        -- Remove processed RoleID from the table
        DELETE FROM @NewlyInsertedRoles WHERE RoleId = @NewRoleID;
    END
END;