
-- =============================================
-- Author:		<Kunal Mali>
-- Create date: <Create Date,,>
-- Description:	<SP to get all the configurations data from the table>
-- =============================================
CREATE PROCEDURE [dbo].[GetConfigurations] 
AS
BEGIN
	SELECT C.ID, C.Name, C.Description, C.Value, C.ModifiedBy ,C.ModifiedOn,ModUser.DisplayName as ModifiedByName
    FROM dbo.Configuration C with (NoLock)
	left  join [dbo].[users] ModUser with (NoLock)
   on ModUser.userid=C.ModifiedBy
   Order by C.Id
END