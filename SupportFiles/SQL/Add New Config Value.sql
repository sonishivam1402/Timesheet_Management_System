--select * from dbo.Configuration

GO
--TO INSERT NEW CONFIGURATION VALUE IN DATABASE
declare @ID int =9
declare @Name varchar(200)='SMTP Server'
Declare @UniqueId varchar(500)='9C3F2848-FD37-4710-A722-11AD59783F89'   --Select newid()
Declare @Description varchar(500)='SMTP Server for email through Code'
declare @Value varchar(4000)='smtp-mail.outlook.com'

if not exists(select 1 from dbo.Configuration where ID=@ID)
	Begin
	insert into dbo.Configuration (ID,UniqueId,Name,Description,Value,CreatedBy,CreatedOn,ModifiedOn,ModifiedBy)
	values(@ID,@UniqueId,@Name,@Description,@Value,1,getdate(),getdate(),1)
	select * from dbo.Configuration where ID=@ID
	End
	else
	Begin
		Select 'CONFIG ID ALREADY EXISTS!'
	End
Go