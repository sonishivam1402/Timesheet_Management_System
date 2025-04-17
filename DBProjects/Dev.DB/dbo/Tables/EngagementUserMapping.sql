CREATE TABLE [dbo].[EngagementUserMapping] (
    [MappingID]      INT      IDENTITY (1, 1) NOT NULL,
    [EngagementID]   INT      NULL,
    [UserID]         INT      NULL,
    [StartDate]      DATE     NULL,
    [EndDate]        DATE     NULL,
    [MaxWeeklyHours] INT      DEFAULT ((0)) NULL,
    [CreatedBy]      INT      NULL,
    [ModifiedBy]     INT      NULL,
    [ModifiedOn]     DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]      DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_EngagementID_Assignment] FOREIGN KEY ([EngagementID]) REFERENCES [dbo].[Engagements] ([EngagementID]),
    CONSTRAINT [FK_UserID_Assignment] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);


GO
-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date,,>
-- Description:	<This trigger is used to update the audit trail table on any change in this table,,>
-- =============================================
CREATE TRIGGER [dbo].[TrgEngagementUserMapping]
ON [dbo].[EngagementUserMapping]
FOR INSERT, DELETE, UPDATE
AS BEGIN
declare @TableName varchar(100)='[dbo].[EngagementUserMapping]'
declare @TableId int='4'
declare @BatchId varchar(50)=newid()

-- Insertions
IF EXISTS (SELECT 1 FROM inserted WHERE NOT EXISTS (SELECT 1 FROM deleted WHERE inserted.MappingID = deleted.MappingID))
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.MappingID,'UserID',null,
		i.UserID,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.MappingID,'StartDate',null,
		i.StartDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.MappingID,'EndDate',null,
		i.EndDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i
    END

-- Deletions
IF EXISTS (SELECT 1 FROM deleted WHERE NOT EXISTS (SELECT 1 FROM inserted WHERE deleted.MappingID = inserted.MappingID))
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,d.MappingID,'UserID',d.UserID,
		NULL,d.ModifiedBy,d.ModifiedOn,@BatchId, 'D' from deleted d

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,d.MappingID,'StartDate',d.StartDate,
		NULL,d.ModifiedBy,d.ModifiedOn,@BatchId, 'D' from deleted d

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,d.MappingID,'EndDate',d.EndDate,
		NULL,d.ModifiedBy,d.ModifiedOn,@BatchId, 'D' from deleted d
    END

-- Updations
IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.MappingID = d.MappingID) 
	begin 
		if update(StartDate)
			begin
				INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,i.MappingID,'StartDate',d.StartDate,
				i.StartDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.MappingID = d.MappingID
				where isnull(i.StartDate,'')<>isnull(d.StartDate,'')
			end
		if update(EndDate)
			begin
				INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,i.MappingID,'EndDate',d.EndDate,
				i.EndDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.MappingID = d.MappingID
				where isnull(i.EndDate,'')<>isnull(d.EndDate,'')
			end
	end
END