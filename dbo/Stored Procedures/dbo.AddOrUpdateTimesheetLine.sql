USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[AddOrUpdateTimesheetLine]    Script Date: 10-12-2024 21:27:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
        SELECT SCOPE_IDENTITY() AS NewLineID;
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
            [Date] = @Date,
            [Comment] = @Comment,
            ModifiedBy = @ModUser,
            ModifiedOn = GETUTCDATE()  -- Update ModifiedOn to current datetime
        WHERE LineID = @LineID;

        -- Return the updated LineID
        SELECT @LineID AS UpdatedLineID;
    END
END;
GO

