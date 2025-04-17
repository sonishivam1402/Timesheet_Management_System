create proc [dbo].[UpdateNotificationSentStatus]
@WorkFlowId int
as
Begin

Update dbo.TimesheetWorkflow set SubmitNotificationSent=1 where WorkflowId=@WorkFlowId
end
