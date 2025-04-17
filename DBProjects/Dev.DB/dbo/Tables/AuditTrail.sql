CREATE TABLE [dbo].[AuditTrail] (
    [LogId]         INT            IDENTITY (1, 1) NOT NULL,
    [TableId]       INT            NULL,
    [TableName]     VARCHAR (100)  NULL,
    [TableKey]      INT            NULL,
    [FieldName]     VARCHAR (50)   NULL,
    [PreviousValue] VARCHAR (1000) NULL,
    [NewValue]      VARCHAR (1000) NULL,
    [ModifiedBy]    INT            NULL,
    [ModifiedOn]    DATETIME       NULL,
    [BatchId]       VARCHAR (50)   NULL,
    [Operation]     CHAR (1)       NULL,
    [TableKey1]     NVARCHAR (10)  NULL,
    [TableKey2]     NVARCHAR (100) NULL
);

