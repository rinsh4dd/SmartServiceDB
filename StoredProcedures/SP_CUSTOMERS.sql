CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,     
    UserId INT NOT NULL,                          
    Name VARCHAR(80) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    AddressId INT NULL,
    ProfileImage VARCHAR(255) NULL,               

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,              

    CONSTRAINT FK_Customers_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_Address FOREIGN KEY (AddressId) REFERENCES Addresses(AddressId),
    CONSTRAINT FK_Customers_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId),
    CONSTRAINT CHK_Customer_Phone_Format CHECK (PhoneNumber NOT LIKE '%[^0-9+]%')
);

ALTER TABLE Customers
ADD CONSTRAINT UQ_Customers_UserId UNIQUE (UserId);

 GO 
 ALTER PROCEDURE [dbo].[SP_CUSTOMERS]
@FLAG VARCHAR(50),

@CUSTOMERID INT = NULL,
@USERID INT = NULL,
@NAME VARCHAR(80) = NULL,
@PHONENUMBER VARCHAR(20) = NULL,
@ADDRESSID INT = NULL,
@PROFILEIMAGE VARCHAR(255) = NULL,

@CREATEDBY INT = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDBY INT = NULL,
@ISACTIVE BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Customers
            (
                UserId,
                Name,
                PhoneNumber,
                AddressId,
                ProfileImage,
                CreatedOn,
                CreatedBy,
                IsDeleted,
                IsActive
            )
            VALUES
            (
                @USERID,
                @NAME,
                @PHONENUMBER,
                @ADDRESSID,
                @PROFILEIMAGE,
                GETDATE(),
                @CREATEDBY,
                0,
                1
            );

            SELECT SCOPE_IDENTITY() AS NewCustomerId;
        END

        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                C.CustomerId,
                C.UserId,
                U.UserName,
                U.UserEmail,
                C.Name,
                C.PhoneNumber,
                C.AddressId,
                C.ProfileImage,
                C.CreatedOn,
                C.CreatedBy,
                C.ModifiedAt,
                C.ModifiedBy,
                C.IsActive,
                C.IsDeleted
            FROM Customers C
            LEFT JOIN Users U ON C.UserId = U.UserId
        END

        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                C.CustomerId,
                C.UserId,
                U.UserName,
                U.UserEmail,
                C.Name,
                C.PhoneNumber,
                C.AddressId,
                C.ProfileImage,
                C.CreatedOn,
                C.CreatedBy,
                C.ModifiedAt,
                C.ModifiedBy,
                C.IsActive,
                C.IsDeleted
            FROM Customers C
            LEFT JOIN Users U ON C.UserId = U.UserId
            WHERE C.CustomerId = @CUSTOMERID AND C.IsDeleted = 0;
        END

        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Customers
            SET
                Name = ISNULL(@NAME, Name),
                PhoneNumber = ISNULL(@PHONENUMBER, PhoneNumber),
                AddressId = ISNULL(@ADDRESSID, AddressId),
                ProfileImage = ISNULL(@PROFILEIMAGE, ProfileImage),
                IsActive = ISNULL(@ISACTIVE, IsActive),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE CustomerId = @CUSTOMERID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Customers
            SET
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY,
                IsActive = 0
            WHERE CustomerId = @CUSTOMERID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_CUSTOMERS.', 16, 1);
        END

    END TRY

    BEGIN CATCH
        DECLARE @ERR_MSG NVARCHAR(MAX), @ERR_SEVERITY INT, @ERR_STATE INT;
        SELECT 
            @ERR_MSG = ERROR_MESSAGE(),
            @ERR_SEVERITY = ERROR_SEVERITY(),
            @ERR_STATE = ERROR_STATE();
        RAISERROR(@ERR_MSG, @ERR_SEVERITY, @ERR_STATE);
    END CATCH
END;
GO

