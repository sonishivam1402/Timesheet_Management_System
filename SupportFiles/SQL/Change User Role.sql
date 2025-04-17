
declare @Email varchar(100)='Ritesh@uciny.com'
declare @isHR bit=1
declare @isManager bit=1
declare @isEmployee bit=1
declare @isAdmin bit=1
-----NO CHANGE AFTER THIS LINE ---------------

declare @ID int
select @ID=UserId From Users where Email=@Email
Delete from UserRolesMapping where UserId=@ID
if @isHR=1 INSERT INTO  dbo.UserRolesMapping(UserID,RoleID,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn)values(@ID,1,@ID,@ID,GetDate(),GetDate())
if @isManager=1 INSERT INTO  dbo.UserRolesMapping(UserID,RoleID,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn)values(@ID,2,@ID,@ID,GetDate(),GetDate())
if @isEmployee=1 INSERT INTO  dbo.UserRolesMapping(UserID,RoleID,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn)values(@ID,3,@ID,@ID,GetDate(),GetDate())
if @isAdmin=1 INSERT INTO  dbo.UserRolesMapping(UserID,RoleID,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn)values(@ID,4,@ID,@ID,GetDate(),GetDate())

