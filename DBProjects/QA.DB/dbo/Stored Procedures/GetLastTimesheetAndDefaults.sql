 
CREATE   PROCEDURE [dbo].[GetLastTimesheetAndDefaults]
    @UserID INT
AS
BEGIN
    DECLARE @DefaultCount INT = 0;
    DECLARE @LastTSDate DATE;
 
	SELECT TOP 1 @LastTSDate = EndDate
	FROM dbo.TimesheetHdr
	WHERE UserID = @UserID AND Status = 2
    ORDER BY EndDate DESC;
 
	IF @LastTSDate IS NULL
	BEGIN
		SELECT @LastTSDate = Value
		FROM [dbo].[Configuration]
		WHERE ID = 1;
	END
 
    BEGIN
        DECLARE @CurrentDate DATE = GETUTCDATE(); 
        SET @DefaultCount = DATEDIFF(DAY, @LastTSDate, @CurrentDate) / 7;
 
        IF DATEDIFF(DAY, @LastTSDate, @CurrentDate) % 7 > 0
        SET @DefaultCount = @DefaultCount + 1;
 
        IF DATEPART(WEEKDAY, @LastTSDate) <= 6 
        BEGIN
            SET @DefaultCount = @DefaultCount - 1; 
        END
 
        IF @DefaultCount < 0
            SET @DefaultCount = 0; 
    END;
 
	IF DATEPART(WEEKDAY, @LastTSDate) = 6
	BEGIN
	SELECT
		[dbo].[GetTimeSheetTitle](DATEADD(DAY, -4, @LastTSDate), @LastTSDate) AS LastTSDate,
		@DefaultCount AS DefaultCount
	END
	ELSE
	BEGIN
	SELECT
		'2024-01-01' AS LastTSDate,
		@DefaultCount AS DefaultCount
	END
END;