

CREATE PROCEDURE [dbo].[GetUserManagerInfo]
AS
BEGIN
 
    SELECT 
		UMM.MappingID,
		U.UserID , 
		U.DisplayName AS UserName, 
		UMM.ManagerID,
		UM.DisplayName AS ManagerName,
		[isPrimary],
		[isSecondary],
		modUsers.DisplayName as ModUserName,
		UMM.ModifiedOn

    FROM 
        [dbo].[UserManagerMapping] as UMM
		Join [dbo].[Users] UM on UMM.ManagerID = UM.UserID
		Join [dbo].[Users] U on UMM.UserID = U.UserID
		left join users as modUsers on modUsers.UserID=umm.ModifiedBy	 
		order by UMM.ModifiedOn desc
END
