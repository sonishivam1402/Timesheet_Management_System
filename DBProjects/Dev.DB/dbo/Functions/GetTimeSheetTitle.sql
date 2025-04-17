

--Select dbo.GetTimeSheetTitle('02-Sep-2024','11-Oct-2024')
CREATE function [dbo].[GetTimeSheetTitle](@StartDate datetime,@EndDate datetime)
returns varchar(100)
as
Begin
declare @title varchar(100)
Set @Title=left(datename(month,@StartDate),3)

declare @WeekNumber int=datediff(ww,datediff(d,0,dateadd(m,datediff(m,7,@StartDate),0)
    )/7*7,dateadd(d,-1,@StartDate))--+1

declare @WeekText as varchar(100)
If @WeekNumber=1 Set @WeekText=' 1st'
If @WeekNumber=2 Set @WeekText=' 2nd'
If @WeekNumber=3 Set @WeekText=' 3rd'
If @WeekNumber=4 Set @WeekText=' 4th'
If @WeekNumber=5 Set @WeekText=' 5th'

SET @title=@Title+ @WeekText +' Week ' 
SET @title=@Title+ ' (' + format(cast(@StartDate as date),'MMM dd') + ' - ' + format(cast(@EndDate as date),'MMM dd')+')'

 
	return @title
end
 
--select left(datename(month,getdate()),3)
