USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[CaptureNotification]    Script Date: 29-11-2024 01:58:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CaptureNotification]
    @UserId INT,
    @NotificationId INT,
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[NotificationRecord] (
        UserId,
        NotificationId,
        IsRead,
        IsActive,
        CreatedBy,
        CreatedOn,
        ModifiedBy,
        ModifiedOn
    )
    VALUES (
        @UserId,
        @NotificationId,
        0,                         -- IsRead (default to 0)
        1,                         -- IsActive (default to 1)
        @ModUser,                  -- CreatedBy
        GETUTCDATE(),              -- CreatedOn
        @ModUser,                  -- ModifiedBy
        GETUTCDATE()               -- ModifiedOn
    );
END;
GO

