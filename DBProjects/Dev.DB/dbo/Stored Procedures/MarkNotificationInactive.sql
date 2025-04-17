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