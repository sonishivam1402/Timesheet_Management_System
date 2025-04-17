CREATE PROCEDURE [dbo].[GetEngagementsForAdmin]
AS
BEGIN
    SELECT 
	E.*,
	U.DisplayName
	FROM [dbo].[Engagements] E WITH (NoLock)
	LEFT JOIN [dbo].[Users] U
	ON E.ModifiedBy = U.UserID
    ORDER BY E.StartDate DESC
END