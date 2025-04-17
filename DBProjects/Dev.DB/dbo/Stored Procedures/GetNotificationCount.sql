CREATE PROCEDURE [dbo].[GetNotificationCount]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Get the count of unread and active notifications for the given user
    SELECT COUNT(RecordId) AS NotificationCount
    FROM NotificationRecord
    WHERE UserId = @UserId
      AND IsRead = 0
      AND IsActive = 1;
END;