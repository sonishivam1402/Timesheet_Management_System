USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[ManageCoOwnerRole]    Script Date: 17-12-2024 16:22:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ManageCoOwnerRole]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- RoleId for "Co-Owner"
    DECLARE @CoOwnerRoleId INT = 7;

    -- Check if the user exists in EngagementUserMapping
    IF EXISTS (
        SELECT 1
        FROM dbo.EngagementUserMapping
        WHERE UserID = @UserId
    )
    BEGIN
        -- If the user exists in EngagementUserMapping, ensure they have the "Co-Owner" role
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.UserRolesMapping
            WHERE UserID = @UserId AND RoleId = @CoOwnerRoleId
        )
        BEGIN
            -- Add the "Co-Owner" role for the user
            INSERT INTO dbo.UserRolesMapping (UserID, RoleId, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
            VALUES (@UserId, @CoOwnerRoleId, @UserId, @UserId, GETUTCDATE(), GETUTCDATE());
        END
    END
    ELSE
    BEGIN
        -- If the user is not in EngagementUserMapping, remove the "Co-Owner" role
        DELETE FROM dbo.UserRolesMapping
        WHERE UserID = @UserId AND RoleId = @CoOwnerRoleId;
    END
END
GO

