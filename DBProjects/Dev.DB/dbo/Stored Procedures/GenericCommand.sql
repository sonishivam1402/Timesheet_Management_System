Create procedure [dbo].[GenericCommand](@CommandId int,@CurrentUser int,@Param1 varchar(50)='',
@Param2 varchar(50)='',@Param3 varchar(50)='',@Param4 varchar(50)=''
)
as
Begin

if @CommandId=1
	Begin
		Select dbo.GetTimeSheetDuration(h.StartDate,h.EndDate) Duration,
		M.StatusName,count(1) TSCount From dbo.Timesheethdr	h with (NoLock),StatusMaster M
		where M.StatusId=h.Status
		Group by dbo.GetTimeSheetDuration(h.StartDate,h.EndDate), M.StatusName
		order by 1
	end

end