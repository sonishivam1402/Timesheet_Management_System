CREATE TABLE [dbo].[Engagements] (
    [EngagementID]         INT            IDENTITY (1, 1) NOT NULL,
    [Title]                NVARCHAR (200) NOT NULL,
    [StartDate]            DATE           NULL,
    [EndDate]              DATE           NULL,
    [Description]          NVARCHAR (MAX) NULL,
    [CreatedBy]            INT            NULL,
    [ModifiedBy]           INT            NULL,
    [ModifiedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]            DATETIME       DEFAULT (getdate()) NULL,
    [IsActive]             BIT            DEFAULT ((1)) NULL,
    [EngagementCategoryID] INT            NULL,
    [EngagementScopeID]    INT            NULL,
    PRIMARY KEY CLUSTERED ([EngagementID] ASC),
    CONSTRAINT [FK_CreatedBy_Engagements] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserID]),
    CONSTRAINT [FK_EngagementScopeID_EngagementScope] FOREIGN KEY ([EngagementScopeID]) REFERENCES [dbo].[EngagementScopeMaster] ([ScopeID]),
    CONSTRAINT [FK_ModifiedBy_Engagements] FOREIGN KEY ([ModifiedBy]) REFERENCES [dbo].[Users] ([UserID])
);


GO
-- =============================================
-- Author:		<Kunal Mali,,Name>
-- Create date: <Create Date,,>
-- Description:	<This trigger is used to update the change in the engagement scope in audit trail table ,,>
-- =============================================
CREATE TRIGGER [dbo].[TrgEngagement]
ON [dbo].[Engagements]
FOR INSERT, UPDATE 
AS BEGIN
declare @TableName varchar(100)='[dbo].[Engagements]'
declare @TableId int='2'
declare @BatchId varchar(50)=newid()


-- Insertions
IF EXISTS (SELECT 1 FROM inserted WHERE NOT EXISTS (SELECT 1 FROM deleted WHERE inserted.EngagementID = deleted.EngagementID))
    BEGIN
      	INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'Title',null,
		i.Title,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'StartDate',null,
		i.StartDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'EndDate',null,
		i.EndDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'Description',null,
		i.Description,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'EngagementCategoryID',null,
		i.EngagementCategoryID,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i

		INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
		select @TableName,@TableId,i.EngagementID,'EngagementScopeID',null,
		i.EngagementScopeID,i.ModifiedBy,i.ModifiedOn,@BatchId, 'I' from inserted i
    END

--Updations
IF EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON i.EngagementID = d.EngagementID) 
	begin
		IF UPDATE (Title) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'Title',d.Title,
				i.Title,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.Title,'')<>isnull(d.Title,'')
			END

		IF UPDATE (StartDate) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'StartDate',d.StartDate,
				i.StartDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.StartDate,'')<>isnull(d.StartDate,'')
			END

		IF UPDATE (EndDate) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'EndDate',d.EndDate,
				i.EndDate,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.EndDate,'')<>isnull(d.EndDate,'')
			END

		IF UPDATE (Description) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'Description',d.Description,
				i.Description,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.Description,'')<>isnull(d.Description,'')
			END

		IF UPDATE (EngagementCategoryID) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'EngagementCategoryID',d.EngagementCategoryID,
				i.EngagementCategoryID,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.EngagementCategoryID,'')<>isnull(d.EngagementCategoryID,'')
			END

		IF UPDATE (EngagementScopeID) 
			BEGIN
      			INSERT INTO dbo.AuditTrail (TableName,TableId,TableKey,FieldName,PreviousValue,NewValue,ModifiedBy,ModifiedOn,BatchId, Operation)
				select @TableName,@TableId,d.EngagementID,'EngagementScopeID',d.EngagementScopeID,
				i.EngagementScopeID,i.ModifiedBy,i.ModifiedOn,@BatchId, 'U' from inserted i join deleted d on i.EngagementID = d.EngagementID
				where isnull(i.EngagementScopeID,'')<>isnull(d.EngagementScopeID,'')
			END
	end
END