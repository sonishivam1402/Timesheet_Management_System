
CREATE   PROCEDURE [dbo].[GetTimesheetDetails]
    @TimesheetID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @TimesheetID IS NULL
    BEGIN
        -- Return all timesheets
        SELECT * FROM dbo.TimesheetHdr;
    END
    ELSE
    BEGIN
        -- Return timesheet by ID
        SELECT * FROM dbo.TimesheetHdr
        WHERE TimesheetID = @TimesheetID;
    END
END
