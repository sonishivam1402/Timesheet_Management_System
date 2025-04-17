CREATE TABLE [dbo].[MenuRoleMapping] (
    [MappingId]  INT      IDENTITY (1, 1) NOT NULL,
    [MenuId]     INT      NULL,
    [RoleId]     INT      NULL,
    [CreatedBy]  INT      NULL,
    [ModifiedBy] INT      NULL,
    [CreatedOn]  DATETIME NULL,
    [ModifiedOn] DATETIME NULL,
    CONSTRAINT [PK_MenuRoleMapping] PRIMARY KEY CLUSTERED ([MappingId] ASC)
);

