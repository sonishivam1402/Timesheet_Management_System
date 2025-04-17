
CREATE   PROCEDURE [dbo].[GetDelegateForManager]
@ManagerId INT	
AS 
BEGIN
	SELECT CONCAT(u.DisplayName,
	' (',
	FORMAT(md.StartDate, 'dd - MMM - yyyy'),
	' Till ',
	FORMAT(md.EndDate, 'dd - MMM - yyyy'),
	')') AS 'DelegateTimeSpan'
	FROM [dbo].[ManagerDelegateMapping] md
	INNER JOIN [dbo].[Users] u
	ON md.DelegateId = u.UserId
	where md.ManagerId = @ManagerId and md.EndDate > GetUTCDate();
END