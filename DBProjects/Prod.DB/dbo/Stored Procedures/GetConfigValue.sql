create procedure [dbo].[GetConfigValue] @ConfigId int
as
Begin
	Select Value from dbo.COnfiguration C where C.ID=@ConfigId
End
