CREATE   PROCEDURE [dbo].[SaveNotifiedEmailLog]
    @UserID INT,
    @ManagerID INT,
    @TimesheetID INT,
    @SentOn DATETIME
AS
BEGIN
    INSERT INTO [dbo].[NotifiedEmailLogs]  
    (
        [UserID],
        [ManagerID],
        [TimesheetID],
		[SentOn]
    )
    VALUES 
    (
        @UserID,
        @ManagerID,
        @TimesheetID,
		GETUTCDATE()
    );
END;