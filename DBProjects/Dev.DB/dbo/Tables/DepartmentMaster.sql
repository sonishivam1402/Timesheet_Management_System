CREATE TABLE [dbo].[DepartmentMaster] (
    [DepartmentID]   INT            NOT NULL,
    [DepartmentName] NVARCHAR (100) NOT NULL,
    [CreatedBy]      INT            NULL,
    [ModifiedBy]     INT            NULL,
    [ModifiedOn]     DATETIME       NULL,
    [CreatedOn]      DATETIME       NULL
);

