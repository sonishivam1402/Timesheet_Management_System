USE [UCITMSDev]
GO
/****** Object:  StoredProcedure [dbo].[GetLastTimesheetAndDefaults]    Script Date: 16-12-2024 15:10:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetLastTimesheetDate]
    @UserID INT
AS
BEGIN
    DECLARE @LastTSDate DATE;

	SELECT TOP 1 @LastTSDate = EndDate
	FROM dbo.TimesheetHdr
	WHERE UserID = @UserID AND Status in(2,3)
    ORDER BY EndDate DESC;

	IF @LastTSDate IS NULL
	BEGIN
		SELECT @LastTSDate = Value
		FROM [dbo].[Configuration]
		WHERE ID = 1;
	END

	IF DATEPART(WEEKDAY, @LastTSDate) = 6
	BEGIN
	SELECT
		[dbo].[GetTimeSheetTitle](DATEADD(DAY, -4, @LastTSDate), @LastTSDate) AS LastTSDate
	END
	ELSE
	BEGIN
	SELECT
		'2024-01-01' AS LastTSDate
	END
END;