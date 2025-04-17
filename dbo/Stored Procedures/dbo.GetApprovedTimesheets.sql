USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetApprovedTimesheets]    Script Date: 09-12-2024 21:45:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GetApprovedTimesheets]
    @ManagerID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Get User IDs of employees managed by the given Manager ID
    DECLARE @EmployeeIDs TABLE (UserID INT);

    INSERT INTO @EmployeeIDs (UserID)
    SELECT UserID
    FROM dbo.UserManagerMapping
    WHERE ManagerID = @ManagerID;

    -- Step 2: Check if @ManagerID is a delegate and add employees of corresponding managers
    IF EXISTS (
        SELECT 1
        FROM dbo.ManagerDelegateMapping
        WHERE DelegateID = @ManagerID
          AND GETUTCDATE() BETWEEN StartDate AND EndDate
    )
    BEGIN
        INSERT INTO @EmployeeIDs (UserID)
        SELECT DISTINCT UserID
        FROM dbo.UserManagerMapping UMM
        INNER JOIN dbo.ManagerDelegateMapping MDM
            ON UMM.ManagerID = MDM.ManagerID
        WHERE MDM.DelegateID = @ManagerID
          AND GETUTCDATE() BETWEEN MDM.StartDate AND MDM.EndDate;
    END;

    -- Step 3: Retrieve timesheet headers for these employees with status = 3
    SELECT 
        hdr.TimesheetID,
        u.DisplayName AS EmployeeName,
        hdr.StartDate,
        hdr.EndDate,
        hdr.HoursTotal,
		wf.SubmittedOn,
		wf.SubmissionComment,
		wf.ApprovedOn,
        wf.ApprovalComment,
		approver.DisplayName AS ApprovedBy,
		[dbo].[GetTimeSheetTitle]([StartDate], [EndDate]) as DisplayTitle,
[dbo].[fnCommentsCount](hdr.TimesheetId) as CommentsCount
		
    FROM 
        dbo.TimesheetHdr hdr
    INNER JOIN 
        dbo.Users u ON hdr.UserID = u.UserID
    INNER JOIN 
        dbo.TimesheetWorkflow wf ON hdr.TimesheetID = wf.TimesheetID
	LEFT JOIN 
        dbo.Users approver ON wf.ApprovedBy = approver.UserID
    WHERE 
        hdr.UserID IN (SELECT UserID FROM @EmployeeIDs)
        AND hdr.Status = 3;
END;
GO

