USE [UCITMSDev]
GO
/****** Object:  StoredProcedure [dbo].[GetUserInfo]    Script Date: 17-12-2024 16:15:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER   PROCEDURE [dbo].[GetUserInfo] 
	-- Add the parameters for the stored procedure here
	@Email nvarchar(256)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT UserID, DisplayName, Email, EmployeeID, isActive
	FROM dbo.Users
	WHERE Email = @Email;
END
