
CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,     
    UserId INT NOT NULL,                          
    Name VARCHAR(80) NOT NULL,
    Email VARCHAR(80) NULL,
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
 GO 

 CREATE PROCEDURE [dbo].[SP_CUSTOMERS]
 @FLAG VARCHAR(20) = NULL,
 @CUSTOMERID INT =NULL,
 @USERID INT =NULL,
 @NAME VARCHAR