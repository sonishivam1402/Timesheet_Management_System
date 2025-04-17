
CREATE FUNCTION [dbo].[fnCommentsCount](@TimesheetId INT)
RETURNS INT 
AS
BEGIN
declare @count int=0
declare @SubmissionComment varchar(255)
declare @RejectionComment varchar(255)
declare @ApprovalComment varchar(255)
select 
@SubmissionComment=trim(isnull(W.SubmissionComment,'')),
@RejectionComment=trim(isnull(W.RejectionComment,'')),
@ApprovalComment=trim(isnull(W.[ApprovalComment],'')) 


from [dbo].[TimesheetWorkflow] W with (NoLock) where W.TimesheetID=@TimesheetId

if @SubmissionComment<>'' Set @count=@count+1
if @RejectionComment<>'' Set @count=@count+1
if @ApprovalComment<>'' Set @count=@count+1	
	RETURN @count
END