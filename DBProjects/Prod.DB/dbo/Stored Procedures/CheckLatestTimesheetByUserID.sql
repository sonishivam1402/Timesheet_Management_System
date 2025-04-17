-- Check for the latest timesheet
CREATE PROCEDURE [dbo].[CheckLatestTimesheetByUserID]
    @UserID INT,
    @TimesheetID INT OUTPUT,
    @StartDate DATE OUTPUT,
    @EndDate DATE OUTPUT,
    @Status INT OUTPUT,
    @TotalHours INT OUTPUT,
    @TotalMinutes INT OUTPUT
AS
BEGIN
    SELECT TOP 1 
        @TimesheetID = TimesheetID,
        @StartDate = StartDate,
        @EndDate = EndDate,
        @Status = Status,
        @TotalHours = HoursTotal,
        @TotalMinutes = MinutesTotal
    FROM dbo.TimesheetHdr
    WHERE UserID = @UserID
    ORDER BY EndDate DESC;
END;
