USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetTimesheetDetailsByUserID]    Script Date: 21-10-2024 10:20:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTimesheetDetailsByUserID]
    @UserID INT  -- Input parameter to filter timesheets by UserID
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
    FROM TimesheetHdr t
    WHERE t.UserID = @UserID;
END
GO


