USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetManagedUsers]    Script Date: 10-12-2024 00:21:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
GO

