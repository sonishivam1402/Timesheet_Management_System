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
    UNIQUE NONCLUSTERED ([UniqueId] ASC),
    UNIQUE NONCLUSTERED ([UniqueId] ASC)
);

