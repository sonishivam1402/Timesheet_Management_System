CREATE TABLE [dbo].[TemplateMaster] (
    [TemplateId]   INT           NOT NULL,
    [Name]         VARCHAR (100) NULL,
    [TemplateText] VARCHAR (MAX) NULL,
    [CreatedBy]    INT           NULL,
    [CreatedOn]    DATETIME      NULL,
    [ModifiedBy]   INT           NULL,
    [ModifiedOn]   DATETIME      NULL,
    CONSTRAINT [PK_TemplateMaster] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);

