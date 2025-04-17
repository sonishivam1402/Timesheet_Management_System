USE [UCITMSDev]
GO

/****** Object:  StoredProcedure [dbo].[GetUserManagerInfo]    Script Date: 10-12-2024 00:23:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



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
GO

