USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[AddOrUpdateTimesheet]    Script Date: 21-10-2024 10:05:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddOrUpdateTimesheet]
    @TimesheetID INT = NULL,  -- Optional, defaults to NULL
    @UserID INT,
    @StartDate DATE,
    @EndDate DATE,
    @Status INT,
    @DaysCount INT,
    @HoursTotal INT,
    @MinutesTotal INT,
    @CreatedBy INT,
    @ModifiedBy INT = NULL  -- Optional, can be provided during update
AS
BEGIN
    SET NOCOUNT ON;

    IF @TimesheetID IS NULL
    BEGIN
        -- Insert into TimesheetHdr and get the new TimesheetID
        INSERT INTO TimesheetHdr (UserID, StartDate, EndDate, Status, DaysCount, HoursTotal, MinutesTotal, CreatedBy, CreatedOn, ModifiedOn)
        VALUES (@UserID, @StartDate, @EndDate, @Status, @DaysCount, @HoursTotal, @MinutesTotal, @CreatedBy, GETDATE(), GETDATE());

        -- Return the newly inserted TimesheetID
        SELECT SCOPE_IDENTITY() AS TimesheetID;
    END
    ELSE
    BEGIN
        -- Update TimesheetHdr
        UPDATE TimesheetHdr
        SET 
            UserID = @UserID,
            StartDate = @StartDate,
            EndDate = @EndDate,
            Status = @Status,
            DaysCount = @DaysCount,
            HoursTotal = @HoursTotal,
            MinutesTotal = @MinutesTotal,
            ModifiedOn = GETDATE(),
            ModifiedBy = ISNULL(@ModifiedBy, @CreatedBy)  -- Use ModifiedBy if provided, otherwise fallback to CreatedBy
        WHERE TimesheetID = @TimesheetID;
    END
END
GO


