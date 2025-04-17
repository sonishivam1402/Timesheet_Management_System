

CREATE   PROCEDURE [dbo].[GetUserInfo] 
	-- Add the parameters for the stored procedure here
	@Email nvarchar(256)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT UserID, DisplayName, Email, EmployeeID
	FROM dbo.Users
	WHERE Email = @Email AND ISNULL( IsActive,1) = 1;
END