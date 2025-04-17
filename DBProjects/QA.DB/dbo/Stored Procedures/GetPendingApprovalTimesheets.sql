
--[dbo].[GetPendingApprovalTimesheets] 7
CREATE PROCEDURE [dbo].[GetPendingApprovalTimesheets]
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

    -- Step 2: Retrieve timesheet headers for these employees with status = 2
    SELECT 
	wf.WorkflowId,
        hdr.TimesheetID,
        u.DisplayName AS EmployeeName,
        hdr.StartDate,
        hdr.EndDate,
        hdr.HoursTotal,
        wf.SubmissionComment,
		wf.SubmittedOn,
		[dbo].[GetTimeSheetTitle]([StartDate], [EndDate]) as DisplayTitle
    FROM 
        dbo.TimesheetHdr hdr
    INNER JOIN 
        dbo.Users u ON hdr.UserID = u.UserID
    INNER JOIN 
        dbo.TimesheetWorkflow wf ON hdr.TimesheetID = wf.TimesheetID
    WHERE 
        hdr.UserID IN (SELECT UserID FROM @EmployeeIDs)
        AND hdr.Status = 2;
END;
