
-- Insert a new timesheet
CREATE PROCEDURE [dbo].[InsertNewTimesheet]
    @UserID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Status INT = 1,
    @TotalHours INT = 0,
    @TotalMinutes INT = 0,
    @Message NVARCHAR(200) OUTPUT
AS
BEGIN
    INSERT INTO TimesheetHdr (UserID, StartDate, EndDate, Status, DaysCount, HoursTotal, MinutesTotal, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
    VALUES (@UserID, @StartDate, @EndDate, @Status, 5, @TotalHours, @TotalMinutes, @UserID, @UserID, GETUTCDATE(), GETUTCDATE());
    
    SET @Message = 'New timesheet created successfully.';
    SELECT SCOPE_IDENTITY() AS TimesheetID;
END;
