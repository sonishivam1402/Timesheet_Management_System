USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetUserNotifications]    Script Date: 02-12-2024 21:36:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetUserNotifications]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        nr.RecordId,
        nr.UserId,
        nr.NotificationId,
        nm.Title,
        nr.Description,
        nm.Icon,
        nr.IsRead,
        nr.IsActive,
		nr.CreatedOn
    FROM 
        NotificationRecord nr
    INNER JOIN 
        NotificationMaster nm ON nr.NotificationId = nm.NotificationID
    WHERE 
        nr.UserId = @UserId and nr.IsActive = 1
    ORDER BY 
        nr.CreatedOn DESC;
END;
GO

