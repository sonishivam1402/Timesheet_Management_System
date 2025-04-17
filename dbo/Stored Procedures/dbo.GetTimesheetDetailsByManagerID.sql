USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetTimesheetDetailsByManagerID]    Script Date: 21-10-2024 10:13:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTimesheetDetailsByManagerID]
    @ManagerID INT  -- Input parameter to filter timesheets by ManagerID
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
    FROM TimesheetHdr t
    WHERE t.CreatedBy = @ManagerID 
       OR t.ModifiedBy = @ManagerID
       OR EXISTS (
            SELECT 1 
            FROM UserManagerMapping umm
            WHERE umm.ManagerID = @ManagerID
            AND umm.UserID = t.UserID
        );
END
GO


