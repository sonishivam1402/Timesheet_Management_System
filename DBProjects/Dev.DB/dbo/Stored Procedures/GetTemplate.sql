 create proc [dbo].[GetTemplate] @TemplateId int
 as
 Begin
 select TemplateText from dbo.TemplateMaster where TemplateId=@TemplateId

 end
