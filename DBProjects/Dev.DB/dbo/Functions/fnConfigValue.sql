


--Select dbo.fnConfigValue('02-Sep-2024','11-Oct-2024')
create function [dbo].[fnConfigValue](@ConfigId int)
returns varchar(4000)
as
Begin

declare @ret varchar(4000)
Select @ret=C.Value from dbo.Configuration C where C.ID=@ConfigId

return @ret
end
 
--select left(datename(month,getdate()),3)