USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[MarkNotificationsAsRead]    Script Date: 02-12-2024 21:37:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MarkNotificationsAsRead]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[NotificationRecord]
    SET IsRead = 1, ModifiedOn = GETUTCDATE()
    WHERE UserId = @UserId AND IsRead = 0 AND IsActive = 1;

    SELECT @@ROWCOUNT;  
END;
GO

