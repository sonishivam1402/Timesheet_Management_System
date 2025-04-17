CREATE TABLE [dbo].[LocationsMaster] (
    [LocationID]   INT            NOT NULL,
    [LocationName] NVARCHAR (100) NOT NULL,
    [CreatedBy]    INT            NULL,
    [ModifiedBy]   INT            NULL,
    [ModifiedOn]   DATETIME       NULL,
    [CreatedOn]    DATETIME       NULL
);

