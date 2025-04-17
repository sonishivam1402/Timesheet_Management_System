USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetTimesheetDetails]    Script Date: 21-10-2024 10:12:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTimesheetDetails]
    @TimesheetID INT = NULL  -- Optional parameter; if NULL, return all timesheets
AS
BEGIN
    SET NOCOUNT ON;

    IF @TimesheetID IS NULL
    BEGIN
        -- Return all timesheets
        SELECT * FROM TimesheetHdr;
    END
    ELSE
    BEGIN
        -- Return timesheet by ID
        SELECT * FROM TimesheetHdr
        WHERE TimesheetID = @TimesheetID;
    END
END
GO


