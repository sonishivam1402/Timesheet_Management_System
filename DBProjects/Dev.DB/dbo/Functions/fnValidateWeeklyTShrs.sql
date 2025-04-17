CREATE FUNCTION [dbo].[fnValidateWeeklyTShrs] 
(
    @TimesheetID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT = 1;
    DECLARE @TotalHours INT = 0;
    DECLARE @TotalMinutes INT = 0;

    -- Calculate total weekly hours and minutes
    SELECT 
        @TotalHours = ISNULL(SUM(Hours), 0),
        @TotalMinutes = ISNULL(SUM(Minutes), 0)
    FROM 
        dbo.TimesheetLines
    WHERE 
        TimesheetID = @TimesheetID;

    -- Convert total minutes to hours and minutes
    SET @TotalHours = @TotalHours + (@TotalMinutes / 60);
    SET @TotalMinutes = @TotalMinutes % 60;

    -- Check if total weekly hours are at least 40
    IF @TotalHours < 40
    BEGIN
        SET @IsValid = 0;
        RETURN @IsValid;
    END

    -- Validate daily hours
    IF EXISTS (
        SELECT 1
        FROM dbo.TimesheetLines
        WHERE 
            TimesheetID = @TimesheetID
            AND DATENAME(WEEKDAY, [Date]) NOT IN ('Saturday', 'Sunday') -- Exclude weekends
            GROUP BY [Date]
            HAVING SUM(Hours) + SUM(Minutes) / 60 < CAST((SELECT [value] FROM [configuration] WHERE [id] = 16) AS INT)
            OR SUM(Hours) + SUM(Minutes) / 60 > CAST((SELECT [value] FROM [configuration] WHERE [id] = 17) AS INT) 
    )
    BEGIN
        SET @IsValid = 0;
    END

    RETURN @IsValid ;
END;