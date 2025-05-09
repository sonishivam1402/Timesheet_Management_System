USE [UCITMSDev]
GO
/****** Object:  StoredProcedure [dbo].[AddOrUpdateApprover]    Script Date: 24-12-2024 00:44:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[AddOrUpdateApprover]
    @UserID INT,
    @PrimaryApproverID INT = NULL,
	@SecondaryApproverID INT = NULL,
    @ModUserID INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN
		IF @PrimaryApproverID is NULL
		BEGIN
			SELECT -4 AS Status, 'Please Select a Primary Approver!' AS Message;
			RETURN;
		END

        IF dbo.fnValidateApprovers(@UserID, @PrimaryApproverID, @SecondaryApproverID) = 0
        BEGIN
            SELECT -1 AS Status,  'Only Managers can be Primary Approvers. The specified User is not a Manager.' AS Message;
            RETURN;
        END

		IF dbo.fnValidateApprovers(@UserID, @PrimaryApproverID, @SecondaryApproverID) = 1 OR dbo.fnValidateApprovers(@UserID, @PrimaryApproverID, @SecondaryApproverID) = 3
        BEGIN
            SELECT -2 AS Status,  'User Cannot be their own Approver.' AS Message;
            RETURN;
        END

		IF dbo.fnValidateApprovers(@UserID, @PrimaryApproverID, @SecondaryApproverID) = 2
		BEGIN
			SELECT -3 AS Status, 'Approvers cannot be same.' AS Message;
			RETURN;
		END
    END
    

    -- Check and process the Primary Approver only if @PrimaryApproverID is not NULL
    IF @PrimaryApproverID IS NOT NULL
    BEGIN
        -- Check if the user already has a primary manager
        IF EXISTS (
            SELECT 1 
            FROM dbo.UserManagerMapping 
            WHERE UserID = @UserID AND isPrimary = 1
        )
        BEGIN
            -- Update the primary manager if the user already has a primary approver
            UPDATE dbo.UserManagerMapping
            SET ManagerID = @PrimaryApproverID,
                ModifiedBy = @ModUserID,
                ModifiedOn = GETUTCDATE()
            WHERE UserID = @UserID AND isPrimary = 1;
        END
        ELSE
        BEGIN
            -- Insert a new row for the primary manager if not already assigned
            INSERT INTO dbo.UserManagerMapping (ManagerID, UserID, isPrimary, isSecondary, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
            VALUES (@PrimaryApproverID, @UserID, 1, 0, @ModUserID, @ModUserID, GETUTCDATE(), GETUTCDATE());
        END
    END

	-- Check and process the Secondary Approver only if @SecondaryApproverID is not NULL
    IF @SecondaryApproverID IS NOT NULL
    BEGIN
        -- Check if the user already has a secondary manager
        IF EXISTS (
            SELECT 1 
            FROM dbo.UserManagerMapping 
            WHERE UserID = @UserID AND isSecondary = 1
        )
        BEGIN
            -- Update the secondary manager if the user already has a secondary approver
            UPDATE dbo.UserManagerMapping
            SET ManagerID = @SecondaryApproverID,
                ModifiedBy = @ModUserID,
                ModifiedOn = GETUTCDATE()
            WHERE UserID = @UserID AND isSecondary = 1;
        END
        ELSE
        BEGIN
            -- Insert a new row for the secondary manager if not already assigned
            INSERT INTO dbo.UserManagerMapping (ManagerID, UserID, isPrimary, isSecondary, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
            VALUES (@SecondaryApproverID, @UserID, 0, 1, @ModUserID, @ModUserID, GETUTCDATE(), GETUTCDATE());
        END

		-- Add logic for Secondary Approver Role Mapping
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.UserRolesMapping 
            WHERE UserID = @SecondaryApproverID AND RoleID = 6
        )
        BEGIN
            INSERT INTO dbo.UserRolesMapping (UserID, RoleID, CreatedBy, CreatedOn)
            VALUES (@SecondaryApproverID, 6, @ModUserID, GETUTCDATE());
        END
    END
	ELSE
	BEGIN
		DELETE FROM dbo.UserManagerMapping WHERE UserID = @UserID AND isSecondary = 1;
	END
	-- Send Notification to employee for approver change
	DECLARE @ApproverName NVARCHAR(255),
			@Template NVARCHAR(255),
            @Description NVARCHAR(255);

	SELECT @ApproverName = DisplayName FROM dbo.Users WHERE UserID = @PrimaryApproverID;
	SELECT @Template = Template FROM dbo.NotificationMaster WHERE NotificationID = 3; 

	SET @Description = @Template + @ApproverName;

	EXEC dbo.CaptureNotification 
        @UserId = @UserID, 
        @NotificationId = 3, 
        @Description = @Description, 
        @ModUser = @ModUserID;
END;

