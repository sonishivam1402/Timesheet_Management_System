CREATE TABLE [dbo].[RolesMaster] (
    [RoleID]     INT            NOT NULL,
    [RoleName]   NVARCHAR (100) NOT NULL,
    [CreatedBy]  INT            NULL,
    [ModifiedBy] INT            NULL,
    [ModifiedOn] DATETIME       DEFAULT (getdate()) NULL,
    [CreatedOn]  DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([RoleID] ASC)
);

