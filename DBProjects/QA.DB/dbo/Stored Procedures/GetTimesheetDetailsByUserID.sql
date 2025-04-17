
CREATE   PROCEDURE [dbo].[GetTimesheetDetailsByUserID]
    @UserID INT 
AS
BEGIN
    SET NOCOUNT ON;

    -- Select timesheets where the UserID matches the input
    SELECT 
        t.TimesheetID,
        t.UserID,
        t.StartDate,
        t.EndDate,
        t.Status,
        t.DaysCount,
        t.HoursTotal,
        t.MinutesTotal,
        t.CreatedBy,
        t.ModifiedBy,
        t.CreatedOn,
        t.ModifiedOn
    FROM dbo.TimesheetHdr t
    WHERE t.UserID = @UserID;
END
