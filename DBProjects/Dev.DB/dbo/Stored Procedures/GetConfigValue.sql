
create procedure [dbo].[GetConfigValue] @ConfigId int
as
Begin
Select dbo.fnConfigValue(@ConfigId) as Value
End
