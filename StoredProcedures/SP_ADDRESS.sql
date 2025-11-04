CREATE TABLE Addresses (
    AddressId INT IDENTITY(1,1) PRIMARY KEY,
    AddressLine VARCHAR(255) NOT NULL,
    Landmark VARCHAR(100) NULL,
    City VARCHAR(80) NOT NULL,
    State VARCHAR(80) NOT NULL,
    Pincode VARCHAR(10) NOT NULL,
    Country VARCHAR(50) NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,                             
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Address_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Address_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Address_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId),
    CONSTRAINT CHK_Pincode_Format CHECK (Pincode NOT LIKE '%[^0-9]%' AND LEN(Pincode) BETWEEN 5 AND 10)
);



CREATE PROCEDURE [dbo].[SP_ADDRESSES]
@FLAG VARCHAR(50) = NULL,

@ADDRESSID INT = NULL,
@ADDRESSLINE VARCHAR(150) = NULL,
@LANDMARK VARCHAR(150) = NULL,
@CITY VARCHAR(80) = NULL,
@STATE VARCHAR(80) = NULL,
@PINCODE VARCHAR(20) = NULL,
@COUNTRY VARCHAR(80) = NULL,

@CREATEDON DATETIME = NULL,
@CREATEDBY INT = NULL,
@MODIFIEDAT DATETIME = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDON DATETIME = NULL,
@DELETEDBY INT = NULL,
@ISDELETED BIT = NULL
AS
BEGIN
    BEGIN TRY

        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Addresses
            (
                AddressLine,
                Landmark,
                City,
                State,
                Pincode,
                Country,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @ADDRESSLINE,
                @LANDMARK,
                @CITY,
                @STATE,
                @PINCODE,
                @COUNTRY,
                ISNULL(@CREATEDON, GETDATE()),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewAddressId;
        END

        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                AddressId,
                AddressLine,
                Landmark,
                City,
                State,
                Pincode,
                Country,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted
            FROM Addresses
            WHERE IsDeleted = 0;
        END

        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                AddressId,
                AddressLine,
                Landmark,
                City,
                State,
                Pincode,
                Country,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted
            FROM Addresses
            WHERE AddressId = @ADDRESSID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Addresses
            SET
                AddressLine = ISNULL(@ADDRESSLINE, AddressLine),
                Landmark = ISNULL(@LANDMARK, Landmark),
                City = ISNULL(@CITY, City),
                State = ISNULL(@STATE, State),
                Pincode = ISNULL(@PINCODE, Pincode),
                Country = ISNULL(@COUNTRY, Country),
                ModifiedAt = ISNULL(@MODIFIEDAT, GETDATE()),
                ModifiedBy = @MODIFIEDBY
            WHERE AddressId = @ADDRESSID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Addresses
            SET
                IsDeleted = 1,
                DeletedOn = ISNULL(@DELETEDON, GETDATE()),
                DeletedBy = @DELETEDBY
            WHERE AddressId = @ADDRESSID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_ADDRESSES.', 16, 1);
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
