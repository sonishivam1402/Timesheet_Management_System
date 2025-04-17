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





