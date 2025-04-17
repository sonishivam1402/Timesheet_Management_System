USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetUserMenuById]    Script Date: 17-12-2024 16:21:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetUserMenuById]
    @UserId INT
AS
BEGIN
    -- Ensure delegate roles are managed
    EXEC [dbo].[ManageDelegateRole] @UserID = @UserId;

	-- Ensure Co-owner roles are managed
    EXEC [dbo].[ManageCoOwnerRole] @UserID = @UserId;

    -- Main menu selection
    SELECT 
        DISTINCT m.ID, 
        m.MenuName, 
        m.ImagePath, 
        m.NavigationPath, 
        m.NavigationType, 
        m.SortOrder, 
        m.IsActive, 
        m.CreatedBy, 
        m.ModifiedBy,
        m.IsDefault
    FROM dbo.Menu m
    INNER JOIN dbo.MenuRoleMapping mr ON m.ID = mr.MenuId
    INNER JOIN dbo.UserRolesMapping ur ON mr.RoleId = ur.RoleId
    WHERE ur.UserId = @UserId 
    AND m.IsActive = 1

    

    ORDER BY SortOrder;
END
GO

