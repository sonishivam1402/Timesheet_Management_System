
--[dbo].[GetTimessheetComments] 110

CREATE PROCEDURE [dbo].[GetTimesheetComments]

-- This Stored Procedure includes the functionality of getting and merging all types of comments
-- This Stored Procedure mainly focuses on the transaction of comments between User and Approver/Rejector

@TimesheetId INT
AS
BEGIN
	declare @tblComments table (
TimesheetId int,
CommentType int,
CommentTypeText Varchar(20),
CommentText varchar(255),
CommentDate datetime,
CommentBy int
)

---Now holding the data of this timesheet in temptable , so we do not have to run queries on the main table
select * into #TempData from [dbo].[TimesheetWorkflow] TSW where TimesheetId= @TimesheetId
--select * from #tempData

---Getting Submitted Comments ---
if exists(Select 1 from #tempData T where trim(isnull(T.SubmissionComment,''))<>'')
	Begin
		Insert into @tblComments(TimesheetId,CommentType,CommentTypeText,CommentText,CommentDate,CommentBy)
		Select TimesheetId,1,'On Submission',T.[SubmissionComment],T.SubmittedOn,T.SubmittedBy from #tempData T
	End

---Getting Rejected Comments ---
if exists(Select 1 from #tempData T where trim(isnull(T.RejectionComment,''))<>'')
	Begin
		Insert into @tblComments(TimesheetId,CommentType,CommentTypeText,CommentText,CommentDate,CommentBy)
		Select TimesheetId,2,'On Rejection',T.RejectionComment,T.RejectedOn,T.RejectedBy from #tempData T
	End

---Getting Approval Comments ---
if exists(Select 1 from #tempData T where trim(isnull(T.ApprovalComment,''))<>'')
	Begin
		Insert into @tblComments(TimesheetId,CommentType,CommentTypeText,CommentText,CommentDate,CommentBy)
		Select TimesheetId,3,'On Approval',T.ApprovalComment,T.ApprovedOn,T.ApprovedBy from #tempData T
	End
select T.*,U.DisplayName CommentByUser From @tblComments T,Users U
Where T.CommentBy=U.UserID
order by commentdate
Drop table [usertmsdev].[tblComments]
Drop table #TempData
END