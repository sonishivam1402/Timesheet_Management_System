USE [UCITMSDev]
GO

/****** Object:  UserDefinedFunction [dbo].[fnConfigValue]    Script Date: 02-12-2024 21:41:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




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
GO

