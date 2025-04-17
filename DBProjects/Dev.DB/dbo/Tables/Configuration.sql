CREATE TABLE [dbo].[Configuration] (
    [ID]          INT            NOT NULL,
    [UniqueId]    VARCHAR (100)  NULL,
    [Name]        VARCHAR (100)  NULL,
    [Description] VARCHAR (500)  NULL,
    [Value]       VARCHAR (4000) NULL,
    [CreatedBy]   INT            NULL,
    [ModifiedBy]  INT            NULL,
    [ModifiedOn]  DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]   DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    UNIQUE NONCLUSTERED ([UniqueId] ASC)
);


GO
CREATE TRIGGER [dbo].[TrgConfiguration_Update]
ON [dbo].[Configuration]
FOR UPDATE 
AS BEGIN
declare @TableName varchar(100)='[dbo].[Configuration]'
declare @TableId int='1'
declare @BatchId varchar(50)=newid()

IF UPDATE (Name) 
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId,Operation)
		select @TableName,@TableId,d.ID,'NAME',d.Name,
		i.Name,i.ModifiedBy,i.ModifiedOn,@BatchId,'U' from inserted i,deleted d
		where isnull(i.Name,'')<>isnull(d.Name,'')
    END

IF UPDATE (Description) 
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId,Operation)
		select @TableName,@TableId,d.ID,'Description',d.Description,
		i.Description,i.ModifiedBy,i.ModifiedOn,@BatchId,'U' from inserted i,deleted d
		where isnull(i.Description,'')<>isnull(d.Description,'')
    END

IF UPDATE (value) 
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId,Operation)
		select @TableName,@TableId,d.ID,
		'Value',d.value,i.value
		,i.ModifiedBy,i.ModifiedOn,@BatchId,'U' from inserted i,deleted d
		where 
		isnull(i.value,'')<>isnull(d.value,'')
    END
	End