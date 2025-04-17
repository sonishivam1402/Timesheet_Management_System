CREATE TABLE [dbo].[StatusMaster] (
    [StatusId]   INT            NOT NULL,
    [StatusName] NVARCHAR (100) NULL,
    [IsActive]   BIT            DEFAULT ((1)) NULL,
    [CreatedBy]  INT            NULL,
    [ModifiedBy] INT            NULL,
    [ModifiedOn] DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]  DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([StatusId] ASC)
);

