USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[ApproveTimesheet]    Script Date: 02-12-2024 21:34:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ApproveTimesheet]
    @TimesheetID INT,
    @ApprovalComment NVARCHAR(500),
    @ModUser INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Update TimesheetHdr to set the status to 3 (approved) and update ModifiedBy
    UPDATE dbo.TimesheetHdr
    SET 
        Status = 3,
        ModifiedBy = @ModUser,
        ModifiedOn = GETUTCDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if the TimesheetHdr update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet not found or already approved.', 16, 1);
        RETURN;
    END

    -- Step 2: Update TimesheetWorkflow with approval details
    UPDATE dbo.TimesheetWorkflow
    SET 
        ApprovalComment = @ApprovalComment,
        ApprovedBy = @ModUser,
        ApprovedOn = GETUTCDATE(),
        ModifiedBy = @ModUser,
        ModifiedOn = GETUTCDATE()
    WHERE TimesheetID = @TimesheetID;

    -- Check if TimesheetWorkflow was updated
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Timesheet workflow entry not found.', 16, 1);
        RETURN;
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
    WHERE NotificationID = 1;

    -- Step 6: Generate description using the UDF
    SET @Description = dbo.fnApprovedOrRejectedTsDescription(@Template, @Duration, @ManagerName);

    -- Step 7: Execute CaptureNotification
    EXEC dbo.CaptureNotification 
        @UserId = @EmployeeID, 
        @NotificationId = 1, 
        @Description = @Description, 
        @ModUser = @ModUser;
END;
GO

