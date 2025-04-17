INSERT INTO [dbo].[MenuRoleMapping] 
(MenuId, RoleId, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
VALUES
(1, 2, 1, 4, GETDATE(), GETDATE()),
(2, 1, 5, 6, GETDATE(), GETDATE());


select *  from MenuRoleMapping

