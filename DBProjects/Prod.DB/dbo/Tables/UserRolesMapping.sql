CREATE TABLE [dbo].[UserRolesMapping] (
    [MappingID]  INT      IDENTITY (1, 1) NOT NULL,
    [UserID]     INT      NULL,
    [RoleID]     INT      NULL,
    [CreatedBy]  INT      NULL,
    [ModifiedBy] INT      NULL,
    [ModifiedOn] DATETIME DEFAULT (getdate()) NULL,
    [CreatedOn]  DATETIME DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([MappingID] ASC),
    CONSTRAINT [FK_UserID_UserRoles] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserID])
);

