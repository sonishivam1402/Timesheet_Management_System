
CREATE PROCEDURE [dbo].[GetTimesheet]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TimesheetID INT;
    DECLARE @StartDate DATE;
    DECLARE @EndDate DATE;
    DECLARE @Status INT;
    DECLARE @NextMonday DATE;
    DECLARE @NextFriday DATE;
    DECLARE @Message NVARCHAR(200);
    DECLARE @TotalHours INT;
    DECLARE @TotalMinutes INT;

    -- Step 1: Check the latest timesheet for the user
    EXEC dbo.[CheckLatestTimesheetByUserID] 
        @UserID = @UserID,
        @TimesheetID = @TimesheetID OUTPUT,
        @StartDate = @StartDate OUTPUT,
        @EndDate = @EndDate OUTPUT,
        @Status = @Status OUTPUT,
        @TotalHours = @TotalHours OUTPUT,
        @TotalMinutes = @TotalMinutes OUTPUT;

    IF @TimesheetID IS NULL
    BEGIN
        -- No timesheet exists, set default dates
        SELECT @NextMonday = CONVERT(date, Value, 23) FROM dbo.Configuration WHERE ID = 1;
        SET @NextFriday = DATEADD(DAY, 4, @NextMonday);

        -- Insert a new timesheet
        EXEC dbo.[InsertNewTimesheet] 
            @UserID = @UserID,
            @StartDate = @NextMonday,
            @EndDate = @NextFriday,
            @Status = 1,
            @TotalHours = 0,
            @TotalMinutes = 0,
            @Message = @Message OUTPUT;

        -- Capture the new TimesheetID
        SET @TimesheetID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        DECLARE @ThisWeekFriday DATE;

		SET @ThisWeekFriday = DATEADD(DAY, 5 - ((DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST - 2) % 7 + 1), 
		    CAST(GETDATE() AS DATE));
		
		IF @Status = 1
		BEGIN
		    SET @Message = 'Returned latest timesheet with pending status.';
		END
		ELSE IF @EndDate = @ThisWeekFriday
		BEGIN
		    SET @Message = 'Cannot add a timesheet with future dates.';
		    -- Return or handle error as needed
		END

        ELSE
        BEGIN
            -- Calculate the next timesheet dates
            EXEC dbo.[CalculateNextTimesheetDates] 
                @EndDate = @EndDate,
                @NextMonday = @NextMonday OUTPUT,
                @NextFriday = @NextFriday OUTPUT;

            -- Insert a new timesheet with calculated dates
            EXEC dbo.[InsertNewTimesheet] 
                @UserID = @UserID,
                @StartDate = @NextMonday,
                @EndDate = @NextFriday,
                @Status = 1,
                @TotalHours = 0,
                @TotalMinutes = 0,
                @Message = @Message OUTPUT;

            -- Capture the new TimesheetID
            SET @TimesheetID = SCOPE_IDENTITY();
        END
    END

    -- Fetch timesheet lines for the current or new TimesheetID
    DECLARE @TimesheetLines TABLE (
        LineID INT,
        TimesheetID INT,
        EngagementID INT,
        TaskID INT,
        Hours INT,
        Minutes INT,
        Date DATE,
        Comment NVARCHAR(1000),
        CreatedBy INT,
        ModifiedBy INT,
        ModifiedOn DATETIME,
        CreatedOn DATETIME
    );

    INSERT INTO @TimesheetLines
    EXEC dbo.[GetTimesheetLines] @TimesheetID = @TimesheetID;

	IF @Status = 1
	BEGIN
    -- Return main timesheet details and lines
		SELECT @TimesheetID AS TimesheetID, 
           @StartDate AS StartDate, 
           @EndDate AS EndDate, 
           @Status AS Status, 
           @TotalHours AS TotalHours, 
           @TotalMinutes AS TotalMinutes, 
           @Message AS Message;
	END

	IF @Status = 1
	BEGIN
		SELECT * FROM @TimesheetLines;
	END
END;
