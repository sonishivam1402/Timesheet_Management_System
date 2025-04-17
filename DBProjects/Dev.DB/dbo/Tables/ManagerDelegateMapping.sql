CREATE TABLE [dbo].[ManagerDelegateMapping] (
    [MappingID]  INT      IDENTITY (1, 1) NOT NULL,
    [ManagerID]  INT      NULL,
    [DelegateID] INT      NULL,
    [StartDate]  DATETIME NULL,
    [EndDate]    DATETIME NULL,
    [CreatedOn]  DATETIME NULL,
    [CreatedBy]  INT      NULL,
    [ModifiedOn] DATETIME NULL,
    [ModifiedBy] INT      NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    FOREIGN KEY ([DelegateID]) REFERENCES [dbo].[Users] ([UserID]),
    FOREIGN KEY ([ManagerID]) REFERENCES [dbo].[Users] ([UserID])
);

