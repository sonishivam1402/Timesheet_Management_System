CREATE PROCEDURE [dbo].[AddOrUpdateTimesheetLine]
    @LineID INT = NULL,             -- To check if it's an update or insert
    @TimesheetID INT,               -- Foreign key to TimesheetHdr table
    @EngagementID INT = NULL,       -- Nullable
    @TaskID INT = NULL,             -- Nullable
    @Hours INT = NULL,              -- Nullable
    @Minutes INT = NULL,            -- Nullable
    @Date DATE = NULL,              -- Nullable
    @Comment NVARCHAR(500) = NULL,  -- Nullable
    @ModUser INT = NULL          -- Nullable
AS
BEGIN

declare @hasAccess bit=0
if not exists (
			
			select 1 from dbo.Timesheethdr T with (NoLock) where T.TimesheetId=@TimesheetId 
			and T.Status in(1,4)
			)
	begin
		return
	end






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
END