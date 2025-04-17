
CREATE PROCEDURE [dbo].[RejectTimesheet]
    @TimesheetID INT,
    @RejectionComment NVARCHAR(500),
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Update TimesheetHdr to set the status to 4 (rejected) and update ModifiedBy with ModUser
    UPDATE dbo.TimesheetHdr
    SET 
        Status = 4,
        ModifiedBy = @ModUser,
        ModifiedOn = GETDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if the TimesheetHdr update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet not found or already rejected.', 16, 1);
        RETURN;
    END

    -- Step 2: Update TimesheetWorkflow with rejection details
    UPDATE dbo.TimesheetWorkflow
    SET 
        RejectionComment = @RejectionComment,
        RejectedBy = @ModUser,
        RejectedOn = GETDATE(),
        ModifiedBy = @ModUser,
        ModifiedOn = GETDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if TimesheetWorkflow was updated; if not, raise an error
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet workflow entry not found.', 16, 1);
    END

	-- Step 3: Get EmployeeID, StartDate, EndDate, ManagerName
    DECLARE @EmployeeID INT, 
            @ManagerName NVARCHAR(100), 
            @StartDate DATE, 
            @EndDate DATE, 
            @Duration NVARCHAR(50), 
            @Template NVARCHAR(255),
            @Description NVARCHAR(255);

    SELECT 
        @EmployeeID = UserID, 
        @StartDate = StartDate, 
        @EndDate = EndDate
    FROM dbo.TimesheetHdr 
    WHERE TimesheetID = @TimesheetID;

    SELECT @ManagerName = DisplayName 
    FROM dbo.Users 
    WHERE UserID = @ModUser;

    -- Step 4: Get duration using the UDF
    SET @Duration = dbo.GetTimeSheetDuration(@StartDate, @EndDate);

    -- Step 5: Fetch template from NotificationMaster
    SELECT @Template = Template 
    FROM dbo.NotificationMaster 
    WHERE NotificationID = 2;

    -- Step 6: Generate description using the UDF
    SET @Description = dbo.fnApprovedOrRejectedTsDescription(@Template, @Duration, @ManagerName);

    -- Step 7: Execute CaptureNotification
    EXEC dbo.CaptureNotification 
        @UserId = @EmployeeID, 
        @NotificationId = 2, 
        @Description = @Description, 
        @ModUser = @ModUser;
END;
