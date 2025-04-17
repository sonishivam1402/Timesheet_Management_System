CREATE PROCEDURE [dbo].[SubmitTimesheetForApproval]

    @TimesheetID INT,

    @UserID INT,

    @SubmissionComment NVARCHAR(500)

AS

BEGIN

    SET NOCOUNT ON;
 
    DECLARE @HoursTotal INT = 0;

    DECLARE @MinutesTotal INT = 0;
 
    -- Step 1: Calculate the total hours and minutes from TimesheetLines for the specified TimesheetID

    SELECT 

        @HoursTotal = ISNULL(SUM(Hours), 0),

    @MinutesTotal = ISNULL(SUM(Minutes), 0)

    FROM 

        dbo.TimesheetLines

    WHERE 

        TimesheetID = @TimesheetID;
 
    -- Convert total minutes to hours and minutes

    SET @HoursTotal = @HoursTotal + (@MinutesTotal / 60);

    SET @MinutesTotal = @MinutesTotal % 60;
 
    -- Step 2: Check if the total hours and minutes are exactly 40 hours and 0 minutes

    IF @HoursTotal <> 40 OR @MinutesTotal <> 0

    BEGIN

        RAISERROR('Total hours and minutes must equal 40 hours 0 minutes to submit the timesheet.', 16, 1);

        RETURN;

    END
 
    -- Step 3: Update TimesheetHdr with status, HoursTotal, and MinutesTotal if the total is 40 hours 0 minutes

    UPDATE dbo.TimesheetHdr

    SET 

        Status = 2,

        HoursTotal = @HoursTotal,

        MinutesTotal = @MinutesTotal

    WHERE TimesheetID = @TimesheetID;
 
    -- Check if the update was successful

    IF @@ROWCOUNT = 0

    BEGIN

        RAISERROR('Timesheet not found or already submitted.', 16, 1);

        RETURN;

    END
 
    -- Step 4: Check if TimesheetID already exists in TimesheetWorkflow

    IF EXISTS (SELECT 1 FROM dbo.TimesheetWorkflow WHERE TimesheetID = @TimesheetID)

    BEGIN

        -- Update the existing record in TimesheetWorkflow

        UPDATE dbo.TimesheetWorkflow

        SET 

            SubmittedOn = GETUTCDATE(),

            SubmittedBy = @UserID,

            SubmissionComment = @SubmissionComment,

            ModifiedBy = @UserID,

            ModifiedOn = GETUTCDATE(),

            SubmitNotificationSent = 0

        WHERE 

            TimesheetID = @TimesheetID;

    END

    ELSE

    BEGIN

        -- Insert a new record into TimesheetWorkflow if no record exists

        INSERT INTO dbo.TimesheetWorkflow (

            TimesheetID,

            SubmittedOn,

            SubmittedBy,

            SubmissionComment,

            CreatedBy,

            ModifiedBy,

            CreatedOn,

            ModifiedOn,

            SubmitNotificationSent

        )

        VALUES (

            @TimesheetID,

            GETUTCDATE(),

            @UserID,

            @SubmissionComment,

            @UserID,

            @UserID,

            GETUTCDATE(),

            GETUTCDATE(),

            0

        );

    END

END;


