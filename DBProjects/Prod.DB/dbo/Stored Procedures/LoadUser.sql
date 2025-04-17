 
Create   proc [dbo].[LoadUser] (@DisplayName varchar(200),@EmailId varchar(200))
as
Begin
	IF not exists (select 1 from Users where trim(Email)=trim(@EmailId))
		Begin
			insert into dbo.users(DisplayName,Email,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn,isActive)
			values(@DisplayName,@EmailId,1,1,getutcdate(),getutcdate(),1)
			declare @EmpRoleId int=3
			declare @NewUserId int
			select @NewUserId=IDENT_CURRENT('users')
			If not exists(Select 1 from [dbo].[UserRolesMapping] U where U.UserID=@NewUserId and U.RoleID=@EmpRoleId)
				Begin
					Insert into  [dbo].[UserRolesMapping] (UserId,RoleId,CreatedBy,ModifiedBy,CreatedOn,ModifiedOn)
					values(@NewUserId,@EmpRoleId,1,1,getutcdate(),getutcdate())
				End
		end
end

