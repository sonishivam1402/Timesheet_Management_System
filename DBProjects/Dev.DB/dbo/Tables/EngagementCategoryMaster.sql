CREATE TABLE [dbo].[EngagementCategoryMaster] (
    [CategoryID]   INT           IDENTITY (1, 1) NOT NULL,
    [CategoryName] VARCHAR (200) NOT NULL,
    [CreatedBy]    INT           NULL,
    [ModifiedBy]   INT           NULL,
    [CreatedOn]    DATETIME      NULL,
    [ModifiedOn]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

