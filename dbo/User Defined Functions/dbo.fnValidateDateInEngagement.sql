-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date, ,>
-- Description:	<This udf is used to validate the start date and end date of the engagement as well as the team member, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnValidateDateInEngagement]
(
	@StartDate DATE,
	@EndDate DATE,
	@TeamMembers dbo.TeamMemberType READONLY
)
RETURNS bit
AS
BEGIN
	DECLARE @isValid BIT = 1;

	-- engagement start and end date validation
	if @StartDate > @EndDate 
	begin 
		set @isValid = 0;
		return @isValid;
	end

	-- team member only and with engagement date validation
	if exists (
		select 1 from @TeamMembers tm
		where (tm.StartDate < @StartDate OR tm.EndDate > @EndDate or tm.StartDate > tm.Enddate) 
	)
	begin 
		set @isValid = 0;
		return @isValid;
	end 

	RETURN @isValid;

END
GO

