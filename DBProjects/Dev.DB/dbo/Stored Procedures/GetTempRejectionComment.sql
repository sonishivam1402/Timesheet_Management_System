CREATE PROCEDURE [dbo].[GetTempRejectionComment]
@ModUser INT,
@TimesheetId INT
AS
BEGIN
	SELECT T.RejectedBy AS 'ManagerId',
	T.RejectionComment AS 'RejectionComment',
	U.DisplayName AS 'ManagerName',
	T.TimesheetId AS 'TimesheetId',
	T.SubmittedBy AS 'SubmittedBy' FROM [dbo].[TimesheetWorkflow] T
	INNER JOIN [dbo].[Users] U 
	ON T.RejectedBy = U.UserId
	WHERE T.SubmittedBy = @ModUser AND T.TimesheetId = @TimesheetId;  
END