USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnCanReviewTimesheet]    Script Date: 08-12-2024 02:19:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE function [dbo].[fnCanReviewTimesheet](@TimesheetId int,@CurrentUserId int)
returns bit
as
Begin
declare @hasAccess bit=0
if exists (
			select 1 from [dbo].[UserManagerMapping] with (noLock)  where UserId in(
			select UserId from TimesheetHdr T with (noLock) where T.TimesheetId=@TimesheetId and T.Status in (2)
			) and ManagerID=@CurrentUserId
			)
	begin
		Set @hasAccess=1
	end

	--  Current user is a delegate of the manager for the employee owning the timesheet
    IF EXISTS (
        SELECT 1
        FROM [dbo].[UserManagerMapping] UMM WITH (NOLOCK)
        INNER JOIN [dbo].[ManagerDelegateMapping] MDM WITH (NOLOCK)
            ON UMM.ManagerID = MDM.ManagerID
        WHERE UMM.UserId IN (
            SELECT T.UserId
            FROM TimesheetHdr T WITH (NOLOCK)
            WHERE T.TimesheetId = @TimesheetId and T.Status in (2)
        )
        AND MDM.DelegateID = @CurrentUserId
        AND GETUTCDATE() BETWEEN MDM.StartDate AND MDM.EndDate
    )
    BEGIN
        SET @hasAccess = 1;
    END

return @hasAccess
end
 

GO

