USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnValidateDailyTShrs]    Script Date: 10-12-2024 21:29:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnValidateDailyTShrs]
(
    @TimesheetID INT,
    @Date DATE,
    @LineID INT = NULL,     -- For updates, exclude the current line
    @NewHours INT,
    @NewMinutes INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @isValid BIT = 0;
    DECLARE @TotalExistingTime FLOAT = 0.0;
    DECLARE @NewTotalTime FLOAT = 0.0;

    -- Calculate the total time for the given date excluding the current line (if updating)
    SELECT 
        @TotalExistingTime = ISNULL(SUM(Hours) + SUM(Minutes) / 60.0, 0.0)
    FROM 
        [dbo].[TimesheetLines]
    WHERE 
        TimesheetID = @TimesheetID
        AND [Date] = @Date
        AND (@LineID IS NULL OR LineID != @LineID);

    -- Calculate the new total time (existing + new time)
    SET @NewTotalTime = @TotalExistingTime + @NewHours + (@NewMinutes / 60.0);

    -- Validate the total time
    IF @NewTotalTime > CAST((SELECT [value] FROM [configuration] WHERE [id] = 17) AS INT)
        SET @isValid = 0; -- Invalid
    ELSE
        SET @isValid = 1; -- Valid

	RETURN @isValid;
END;
GO

