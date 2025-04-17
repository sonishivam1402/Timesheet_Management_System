
CREATE PROCEDURE [dbo].[SubmitTimesheetForApproval]
    @TimesheetID INT,
    @UserID INT,
    @SubmissionComment NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Validate weekly hours using the UDF
    IF dbo.fnValidateWeeklyTShrs(@TimesheetID) = 0
    BEGIN
		RAISERROR('Time Validation failed. Please Adjust hours.', 16, 1);
        RETURN;
    END

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
    -- Step 3: Update TimesheetHdr with status, HoursTotal, and MinutesTotal if the total is 40 hours 0 minutes
    UPDATE dbo.TimesheetHdr
    SET 
        Status = 2,
        HoursTotal = @TotalHours,
        MinutesTotal = @TotalMinutes
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

	DECLARE @ManagerID INT, 
            @EmployeeName NVARCHAR(100), 
            @StartDate DATE, 
            @EndDate DATE, 
            @Duration NVARCHAR(50), 
            @Template NVARCHAR(255),
            @Description NVARCHAR(255);

	SELECT 
        @StartDate = StartDate, 
        @EndDate = EndDate
    FROM dbo.TimesheetHdr 
    WHERE TimesheetID = @TimesheetID;

    SELECT @EmployeeName = DisplayName 
    FROM dbo.Users 
    WHERE UserID = @UserID;

	SELECT @ManagerID = ManagerID
	FROM dbo.UserManagerMapping
	WHERE UserID = @UserID AND ISPRIMARY = 1;

	SET @Duration = dbo.GetTimeSheetDuration(@StartDate, @EndDate);

	SELECT @Template = Template 
    FROM dbo.NotificationMaster 
    WHERE NotificationID = 6;

	SET @Description = @EmployeeName + @Template + @Duration;

	EXEC dbo.CaptureNotification 
        @UserId = @ManagerID, 
        @NotificationId = 6, 
        @Description = @Description, 
        @ModUser = @UserID;
END;