
CREATE PROCEDURE [dbo].[GetManagedUsers]
    @ManagerID INT
AS
BEGIN
    SELECT DISTINCT
        u.UserID,
        u.DisplayName,
        u.Email,
		umm.isPrimary,
		umm.isSecondary
    FROM dbo.Users u
    INNER JOIN dbo.UserManagerMapping umm ON u.UserID = umm.UserID
    WHERE umm.ManagerID = @ManagerID
    AND u.IsActive = 1  
    ORDER BY u.DisplayName;
END
