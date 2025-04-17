
CREATE   PROCEDURE [dbo].[GetTimesheetDetailsByManagerID]
    @ManagerID INT 
AS
BEGIN
    SET NOCOUNT ON;

    -- Select timesheets where the ManagerID matches either CreatedBy or ModifiedBy
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
    WHERE t.CreatedBy = @ManagerID 
       OR t.ModifiedBy = @ManagerID
       OR EXISTS (
            SELECT 1 
            FROM dbo.UserManagerMapping umm
            WHERE umm.ManagerID = @ManagerID
            AND umm.UserID = t.UserID
        );
END
