
CREATE PROCEDURE [dbo].[GetEmployeePreviousTimesheets]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve previous timesheets for the specified UserID, with Status 2 or 3
    SELECT 
        th.[TimesheetID],
        th.[StartDate],
        th.[EndDate],
		th.[Status],
        th.[HoursTotal] AS TotalHours,
        tw.[SubmittedOn],
        tw.[SubmissionComment],
        tw.[ApprovedOn],
        tw.[ApprovalComment],
        u.[DisplayName] AS ApprovedBy,
		[dbo].[GetTimeSheetTitle]([StartDate], [EndDate]) as DisplayTitle
    FROM 
        [dbo].[TimesheetHdr] th
    INNER JOIN 
        [dbo].[TimesheetWorkflow] tw ON th.[TimesheetID] = tw.[TimesheetID]
    LEFT JOIN 
        [dbo].[Users] u ON tw.[ApprovedBy] = u.[UserID]  -- Join with Users to get ApprovedBy name
    WHERE 
        th.[UserID] = @UserID
        AND th.[Status] IN (2, 3, 4);
END;
