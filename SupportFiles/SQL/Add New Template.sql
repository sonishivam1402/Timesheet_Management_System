---- FILE THESE PARAMS ------
declare @TemplateId int=00000
Declare @Name varchar(100)='XXXXXXXXXXXXXX'
Declare @Text varchar(max)=' XXXX
XXXX
XXXXX'
---------------------
Delete from dbo.TemplateMaster where TemplateId=@TemplateId
INsert into dbo.TemplateMaster(TemplateId,Name,TemplateText,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn)
values(@TemplateId,@Name,@Text,1,getdate(),1,getdate())

select * from dbo.TemplateMaster where TemplateId=@TemplateId
 
 --dbo.GetTemplate 1
