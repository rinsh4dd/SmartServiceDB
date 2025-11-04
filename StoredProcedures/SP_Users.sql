 
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(80) NOT NULL,
    UserEmail VARCHAR(80) UNIQUE NOT NULL,
    PasswordHash VARCHAR(128) NOT NULL,
    Role VARCHAR(20) CHECK (Role IN ('Admin','Customer','Technician','Staff')),
    IsActive BIT DEFAULT 1,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT(0) NOT NULL,

    CONSTRAINT CHK_UserName_Length CHECK (LEN(UserName) BETWEEN 3 AND 30),
    CONSTRAINT CHK_UserEmail_Format CHECK (
        UserEmail LIKE '_%@_%._%' 
        AND UserEmail NOT LIKE '%@%@%' 
        AND UserEmail NOT LIKE '% %'
    ),

    CONSTRAINT FK_Users_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

GO

CREATE PROCEDURE [dbo].[SP_USERS]
@FLAG VARCHAR(50)=NULL,
@USERID INT  =NULL,
@USERNAME VARCHAR(80) =NULL,
@USEREMAIL VARCHAR(80)=NULL,
@PASSWORDHASH VARCHAR(128)=NULL,
@ROLE VARCHAR(20)=NULL,
@ISACTIVE BIT =NULL,
@CREATEDON DATETIME =NULL,
@CREATEDBY INT =NULL,
@MODIFIEDAT DATETIME =NULL,
@MODIFIEDBY INT =NULL,
@DELETEDON DATETIME =NULL,
@DELETEDBY INT =NULL,
@ISDELETED BIT =NULL
AS
BEGIN
    BEGIN TRY

        IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                UserId,
                UserName,
                UserEmail,
                PasswordHash,
                Role,
                IsActive,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted
            FROM Users;
        END


        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                UserId,
                UserName,
                UserEmail,
                PasswordHash,
                Role,
                IsActive,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted
            FROM Users
            WHERE UserId = @USERID;
        END

        ELSE IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Users
            (
                UserName,
                UserEmail,
                PasswordHash,
                Role,
                IsActive,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @USERNAME,
                @USEREMAIL,
                @PASSWORDHASH,
                @ROLE,
                @ISACTIVE,
                GETDATE(),
                @CREATEDBY,
                0
            );
        END

      ELSE IF @FLAG = 'UPDATE'
BEGIN
    UPDATE Users
    SET
        UserName    = ISNULL(@USERNAME, UserName),
        UserEmail   = ISNULL(@USEREMAIL, UserEmail),
        Role        = ISNULL(@ROLE, Role),
        IsActive    = ISNULL(@ISACTIVE, IsActive),
        ModifiedAt  = GETDATE(),
        ModifiedBy  = @MODIFIEDBY
    WHERE UserId = @USERID


    SELECT 'User updated successfully.' AS Message;
END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Users
            SET
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE UserId = @USERID;
        END

    END TRY
    BEGIN CATCH
        DECLARE @ERR_MSG VARCHAR(MAX),
                @ERR_SEVERITY INT,
                @ERR_STATE INT;
        SELECT
            @ERR_MSG = ERROR_MESSAGE(),
            @ERR_SEVERITY = ERROR_SEVERITY(),
            @ERR_STATE = ERROR_STATE();
        RAISERROR(@ERR_MSG, @ERR_SEVERITY, @ERR_STATE);
    END CATCH
END;