CREATE TABLE [dbo].[UserManagerMapping] (
    [MappingID]   INT      IDENTITY (1, 1) NOT NULL,
    [ManagerID]   INT      NULL,
    [UserID]      INT      NULL,
    [isPrimary]   BIT      DEFAULT ((1)) NULL,
    [CreatedBy]   INT      NULL,
    [ModifiedBy]  INT      NULL,
    [ModifiedOn]  DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]   DATETIME DEFAULT (getdate()) NULL,
    [isSecondary] BIT      CONSTRAINT [DF_UserManagerMapping_isSecondary] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_ManagerID] FOREIGN KEY ([ManagerID]) REFERENCES [dbo].[Users] ([UserID]),
    CONSTRAINT [FK_UserID] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);


GO
-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date,,>
-- Description:	<This sp is used to add audit trail data after an update or insert into UserManagerMapping table,,>
-- =============================================
CREATE TRIGGER [dbo].[TrgUserManagerMapping]
ON [dbo].[UserManagerMapping]
FOR UPDATE, DELETE, INSERT
AS BEGIN
declare @TableName varchar(100)='[dbo].[UserManagerMapping]'
declare @TableId int='3'
declare @BatchId varchar(50)=newid()

-- Updations
IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.MappingID = d.MappingID) 
	begin
	IF UPDATE (ManagerID) 
		BEGIN
      		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
			select @TableName,@TableId,d.MappingID,'ManagerID',
			CONCAT(d.ManagerID, ' (', CASE WHEN d.isPrimary = 1 THEN 'Primary' ELSE 'Secondary' END, ')'), 
			CONCAT(i.ManagerID, ' (', CASE WHEN i.isPrimary = 1 THEN 'Primary' ELSE 'Secondary' END, ')'),
			i.ModifiedBy,i.ModifiedOn,@BatchId,
			'U' from inserted i join deleted d on i.MappingID = d.MappingID
			where isnull(i.ManagerID,'')<>isnull(d.ManagerID,'')
		END
	end

-- Deletions
if exists(select 1 from deleted where MappingID not in (select MappingID from inserted))
	begin
		INSERT INTO dbo.AuditTrail (TableName, TableId, TableKey, FieldName, PreviousValue, NewValue, ModifiedBy, ModifiedOn, BatchId, Operation)
		SELECT 
			@TableName,@TableId,d.MappingID,'ManagerID',
			CONCAT(d.ManagerID, ' (', CASE WHEN d.isPrimary = 1 THEN 'Primary' ELSE 'Secondary' END, ')'),
			'None',d.ModifiedBy, GETUTCDATE(), @BatchId,
			'D'
		FROM 
			deleted d;
	end

-- Insertions
if exists(select 1 from inserted i where not exists (select 1 from deleted d where i.MappingID = d.MappingID))
	begin
		--primary
		INSERT INTO dbo.AuditTrail (TableName, TableId, TableKey, FieldName, PreviousValue, NewValue, ModifiedBy, ModifiedOn, BatchId, Operation)
		SELECT 
			@TableName,@TableId,i.MappingID,'ManagerID',
			'None',
			CONCAT(i.ManagerID, ' (', CASE WHEN i.isPrimary = 1 THEN 'Primary' ELSE 'Secondary' END, ')'),
			i.ModifiedBy, i.ModifiedOn, @BatchId,
			'I'
		FROM 
			inserted i
		WHERE 
			isPrimary = 1 or isSecondary = 1
	end
END