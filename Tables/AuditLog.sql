USE SmartServeDB
GO

CREATE TABLE AuditLogs (
    AuditId INT IDENTITY(1,1) PRIMARY KEY,
    TableName VARCHAR(100) NOT NULL,
    RecordId INT NULL,
    ActionType VARCHAR(20) CHECK (ActionType IN ('INSERT', 'UPDATE', 'DELETE')) NOT NULL,
    OldValues NVARCHAR(MAX) NULL,
    NewValues NVARCHAR(MAX) NULL,
    PerformedBy INT NULL,
    PerformedOn DATETIME DEFAULT GETDATE() NOT NULL,
    Remarks NVARCHAR(255) NULL
);
