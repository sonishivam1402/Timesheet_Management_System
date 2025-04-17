CREATE PROCEDURE [dbo].[AddOrUpdateTimesheetLine]
    @LineID INT = NULL,             -- To check if it's an update or insert
    @TimesheetID INT,               -- Foreign key to TimesheetHdr table
    @EngagementID INT = NULL,       -- Nullable
    @TaskID INT = NULL,             -- Nullable
    @Hours INT = NULL,              -- Nullable
    @Minutes INT = NULL,            -- Nullable
    @Date DATE = NULL,              -- Nullable
    @Comment NVARCHAR(500) = NULL,  -- Nullable
    @ModUser INT = NULL             -- Nullable
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Validate total time using the UDF
    IF dbo.fnValidateDailyTShrs(@TimesheetID, @Date, @LineID, ISNULL(@Hours, 0), ISNULL(@Minutes, 0)) = 0
    BEGIN
        -- Return error code and message
        SELECT -1 AS Status, 'Maximum daily hours limit exceeded. Please adjust the time.' AS Message;
        RETURN;
    END

	IF dbo.fnCanViewEngagement (@EngagementID, @ModUser) = 0
	BEGIN
		SELECT -1 AS Status, 'You are not authorised to add this engagement.' AS Message;
        RETURN;
	END

	IF NOT EXISTS (
        SELECT 1
        FROM dbo.EngagementTaskMapping
        WHERE EngagementID = @EngagementID AND TaskID = @TaskID
    )
    BEGIN
        SELECT -1 AS Status, 'The selected task is not associated with the given engagement.' AS Message;
        RETURN;
    END

	--  Validate date falls within timesheet start and end dates
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.TimesheetHdr
        WHERE TimesheetID = @TimesheetID
          AND @Date BETWEEN StartDate AND DATEADD(DAY, 6, StartDate)
    )
    BEGIN
        SELECT -1 AS Status, 'The date is outside the valid range of the timesheet.' AS Message;
        RETURN;
    END
    -- Step 2: Proceed with Insert or Update
    IF @LineID IS NULL
    BEGIN
        -- Insert new timesheet line
        INSERT INTO [dbo].[TimesheetLines] 
        (
            TimesheetID,
            EngagementID,
            TaskID,
            Hours,
            Minutes,
            [Date],
            [Comment],
            CreatedBy,
            CreatedOn,
            ModifiedBy,
            ModifiedOn
        )
        VALUES 
        (
            @TimesheetID,
            @EngagementID,
            @TaskID,
            @Hours,
            @Minutes,
            @Date,
            @Comment,
            @ModUser,
            GETUTCDATE(),       -- Set CreatedOn to current datetime
            @ModUser,
            GETUTCDATE()        -- Set ModifiedOn to current datetime
        );

        -- Return the new LineID
        SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewLineID;
    END
    ELSE
    BEGIN
        -- Update existing timesheet line
        UPDATE [dbo].[TimesheetLines]
        SET 
            TimesheetID = @TimesheetID,
            EngagementID = @EngagementID,
            TaskID = @TaskID,
            Hours = @Hours,
            Minutes = @Minutes,
            [Comment] = @Comment,
            ModifiedBy = @ModUser,
            ModifiedOn = GETUTCDATE()  -- Update ModifiedOn to current datetime
        WHERE LineID = @LineID;

        -- Return the updated LineID
        SELECT @LineID AS UpdatedLineID;
    END
END;