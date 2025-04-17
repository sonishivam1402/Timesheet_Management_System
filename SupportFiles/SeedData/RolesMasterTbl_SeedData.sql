INSERT INTO [dbo].[RolesMaster] 
(RoleID,RoleName, CreatedBy, ModifiedBy, CreatedOn, ModifiedOn)
VALUES
(1,'HR', 1, 4, GETDATE(), GETDATE()),
(2,'BA', 6, 4, GETDATE(), GETDATE()),
(3,'Manager', 5, 6, GETDATE(), GETDATE()),
(4,'Developer', 5, 6, GETDATE(), GETDATE());

select * from [RolesMaster] 