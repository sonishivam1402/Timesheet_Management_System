
CREATE PROCEDURE [dbo].[GetPendingApprovals]
	@UserID INT
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #PendingApprovalDetails (
		WorkflowId INT,
		TimesheetID INT,
		EmployeeName NVARCHAR(500),
		StartDate DATE,
        EndDate DATE,
        HoursTotal INT,
		SubmissionComment NVARCHAR(500),
        SubmittedOn DATE,
		DisplayTitle NVarchar(500),
		CommentsCount INT
	)

	INSERT INTO #PendingApprovalDetails
	EXEC [dbo].[GetPendingApprovalTimesheets] @ManagerID = @UserID;

	SELECT COUNT(*) AS TotalCount
	FROM #PendingApprovalDetails

	DROP TABLE #PendingApprovalDetails;
END