
--[dbo].[GetUserMenuById] 7
CREATE PROCEDURE [dbo].[GetUserMenuById]
    @UserId INT
AS
BEGIN

	EXEC [dbo].[ManageDelegateRole] @UserID = @UserId;

    SELECT 
        Distinct m.ID, 
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
    ORDER BY m.SortOrder;
END