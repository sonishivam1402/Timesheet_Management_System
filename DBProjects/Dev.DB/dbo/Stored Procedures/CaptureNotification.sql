CREATE PROCEDURE [dbo].[CaptureNotification]
    @UserId INT,
    @NotificationId INT,
    @Description NVARCHAR(255),
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[NotificationRecord] (
        UserId,
        NotificationId,
        Description,
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
        @Description,
        0,                         -- IsRead (default to 0)
        1,                         -- IsActive (default to 1)
        @ModUser,                  -- CreatedBy
        GETUTCDATE(),              -- CreatedOn
        @ModUser,                  -- ModifiedBy
        GETUTCDATE()               -- ModifiedOn
    );
END;