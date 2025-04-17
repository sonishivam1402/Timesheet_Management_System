CREATE TABLE [dbo].[EngagementScopeMaster] (
    [ScopeID]     INT            NOT NULL,
    [Description] NVARCHAR (255) NOT NULL,
    [IsActive]    BIT            DEFAULT ((1)) NOT NULL,
    [CreatedBy]   INT            NULL,
    [CreatedOn]   DATETIME       DEFAULT (getutcdate()) NOT NULL,
    [ModifiedBy]  INT            NULL,
    [ModifiedOn]  DATETIME       DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ScopeID] ASC)
);

