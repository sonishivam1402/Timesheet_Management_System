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