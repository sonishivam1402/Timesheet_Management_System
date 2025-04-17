


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

    -- Step 2: Retrieve timesheet headers for these employees with status = 3
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
		[dbo].[GetTimeSheetTitle]([StartDate], [EndDate]) as DisplayTitle
		
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
