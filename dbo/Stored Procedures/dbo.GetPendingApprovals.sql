USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetPendingApprovals]    Script Date: 04-11-2024 15:15:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetPendingApprovals]
	@UserID INT
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #PendingApprovalDetails (
		TimesheetID INT,
		EmployeeName NVARCHAR(500),
		StartDate DATE,
        EndDate DATE,
        HoursTotal INT,
		SubmissionComment NVARCHAR(500),
        SubmittedOn DATE
	)

	INSERT INTO #PendingApprovalDetails
	EXEC [dbo].[GetPendingApprovalTimesheets] @ManagerID = @UserID;

	SELECT COUNT(*) AS TotalCount
	FROM #PendingApprovalDetails

	DROP TABLE #PendingApprovalDetails;
END
GO


