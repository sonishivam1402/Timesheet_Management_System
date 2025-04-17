
CREATE     PROCEDURE [dbo].[GetNotifiedEmailLog]
AS
BEGIN
    -- Temporary table to store Timesheet data and workflow details
    SELECT T.TimesheetID, T.UserID, usrSubmitteBy.DisplayName AS [UserName], 
           T.StartDate, T.EndDate, T.Status, W.SubmittedOn,
           DATEDIFF(DAY, W.SubmittedOn, GETUTCDate()) AS DaysDue, 
           0 AS ManagerId, 
           CAST('' AS VARCHAR(100)) AS ManagerName,  
           CAST('' AS VARCHAR(100)) AS ManagerEmail,
		   dbo.GetTimeSheetDuration (t.startdate, t.enddate) as tsDuration, W.SubmissionComment
    INTO #TempData
    FROM TimesheetHdr T
    INNER JOIN [dbo].[TimesheetWorkflow] W ON T.TimesheetID = W.TimesheetID
    INNER JOIN Users usrSubmitteBy ON usrSubmitteBy.UserID = T.UserID
    WHERE T.Status = 2

    -- Getting Manager details for the users
    UPDATE T
    SET ManagerId = UM.ManagerID, 
        ManagerName = usrManger.DisplayName, 
        ManagerEmail = usrManger.Email
    FROM #TempData T
    INNER JOIN dbo.UserManagerMapping UM ON T.UserID = UM.UserID 
    INNER JOIN Users usrManger ON UM.ManagerID = usrManger.UserID
    WHERE UM.isPrimary = 1

    -- Get the most recent SentOn date from NotifiedEmailLogs for each UserID, ManagerID, and TimesheetID
    DECLARE @SentOn DATETIME;
    
    -- Add the SentOn date to the result set
    SELECT T.*, 
           (SELECT TOP 1 SentOn
            FROM NotifiedEmailLogs
            WHERE UserID = T.UserID AND ManagerID = T.ManagerId AND TimesheetID = T.TimesheetID
            ORDER BY SentOn DESC) AS LastNotifiedOn
    FROM #TempData T
    ORDER BY DaysDue DESC;

    -- Clean up the temporary table
    DROP TABLE #TempData;
END;