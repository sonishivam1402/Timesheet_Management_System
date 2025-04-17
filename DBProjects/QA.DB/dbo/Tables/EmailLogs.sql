CREATE TABLE [dbo].[EmailLogs] (
    [LogId]     INT           IDENTITY (1, 1) NOT NULL,
    [Category]  VARCHAR (50)  NULL,
    [SentTo]    VARCHAR (100) NULL,
    [SentFrom]  VARCHAR (100) NULL,
    [Subject]   VARCHAR (500) NULL,
    [EmailBody] VARCHAR (MAX) NULL,
    [CC]        VARCHAR (200) NULL,
    [BCC]       VARCHAR (200) NULL,
    [SentOn]    DATETIME      NULL
);

