CREATE PROCEDURE [dbo].[GetTimesheetLines]
    @TimesheetID INT
AS
BEGIN
    -- Select timesheet lines where the TimesheetID matches the provided parameter
    SELECT 
        [LineID],
        [TimesheetID],
        [EngagementID],
        [TaskID],
        [Hours],
        [Minutes],
        [Date],
        [Comment],
        [CreatedBy],
        [ModifiedBy],
        [ModifiedOn],
        [CreatedOn]
    FROM 
        [dbo].[TimesheetLines]
    WHERE 
        [TimesheetID] = @TimesheetID;
END

