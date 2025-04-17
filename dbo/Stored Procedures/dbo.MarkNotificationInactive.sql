USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[MarkNotificationInactive]    Script Date: 02-12-2024 21:36:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MarkNotificationInactive]
    @RecordId INT,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE NotificationRecord
    SET 
        IsActive = 0,
        ModifiedBy = @ModUser,
        ModifiedOn = GETUTCDATE()
    WHERE 
        RecordId = @RecordId;

	SELECT @@ROWCOUNT;
END;
GO

