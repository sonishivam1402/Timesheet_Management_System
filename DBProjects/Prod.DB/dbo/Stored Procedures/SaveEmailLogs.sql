CREATE proc [dbo].[SaveEmailLogs]
@Category varchar(50),
@SentTo varchar(100),
@SentFrom varchar(100),
@Subject varchar(500),
@EmailBody varchar(max),
@CC varchar(200),
@BCC varchar(200)
as
Begin

insert into dbo.EmailLogs(Category,SentTo,SentFrom,Subject,EmailBody,SentOn,CC,BCC)
values(@Category,@SentTo,@SentFrom,@Subject,@EmailBody,GETUTCDATE(),@CC,@BCC)

end
