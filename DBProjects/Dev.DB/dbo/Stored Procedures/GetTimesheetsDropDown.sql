

CREATE PROCEDURE [dbo].[GetTimesheetsDropDown]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve timesheet records with Status 1 or 4 for the specified UserID
    SELECT 
        [TimesheetID],
        [UserID],
        [StartDate],
        [EndDate],
        [Status],
        [HoursTotal],
        [MinutesTotal],
		[dbo].[GetTimeSheetTitle]([StartDate], [EndDate]) as DisplayTitle
    FROM 
        [dbo].[TimesheetHdr]
    WHERE 
        [UserID] = @UserID 
        AND [Status] IN (1, 4);
END;
