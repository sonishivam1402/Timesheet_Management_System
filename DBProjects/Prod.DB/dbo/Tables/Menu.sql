CREATE TABLE [dbo].[Menu] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [MenuName]       NVARCHAR (100) NOT NULL,
    [ImagePath]      NVARCHAR (500) NULL,
    [NavigationPath] NVARCHAR (500) NULL,
    [NavigationType] NVARCHAR (200) NULL,
    [SortOrder]      INT            NULL,
    [IsActive]       BIT            DEFAULT ((1)) NULL,
    [CreatedBy]      INT            NULL,
    [ModifiedBy]     INT            NULL,
    [ModifiedOn]     DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]      DATETIME       DEFAULT (getdate()) NULL,
    [isDefault]      BIT            DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

