USE SmartServeDB;
GO

DROP TABLE IF EXISTS Users;
GO

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,

    -- ✅ Username Validation
    UserName VARCHAR(30) NOT NULL,
    CONSTRAINT CHK_UserName_Length CHECK (LEN(UserName) BETWEEN 3 AND 30),

    -- ✅ Email Validation
    UserEmail VARCHAR(80) NOT NULL UNIQUE,
    CONSTRAINT CHK_UserEmail_Format CHECK (
        UserEmail LIKE '_%@_%._%'         -- contains @ and .
        AND UserEmail NOT LIKE '%@%@%'    -- only 1 @
        AND UserEmail NOT LIKE '% %'      -- no spaces
    ),

    -- ✅ Password Validation
    PasswordHash VARCHAR(128) NOT NULL,
    CONSTRAINT CHK_Password_Length CHECK (LEN(PasswordHash) BETWEEN 20 AND 128),

    -- ✅ Role validation
    Role VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_Role CHECK (Role IN ('Admin', 'Customer', 'Technician', 'Staff')),

    -- ✅ Active flags
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,

    -- ✅ Audit fields
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,

    -- ✅ FKs
    CONSTRAINT FK_Users_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);
GO
