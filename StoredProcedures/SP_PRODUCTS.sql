CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    UNQBC VARCHAR(50) UNIQUE NOT NULL,
    CategoryId INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    CostPrice DECIMAL(18,2) NOT NULL,
    QuantityInStock INT DEFAULT 0 CHECK (QuantityInStock >= 0),
    IsActive BIT DEFAULT 1 NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryId) REFERENCES ProductCategory(CategoryId),
    CONSTRAINT FK_Products_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Products_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Products_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_PRODUCTS]
@FLAG VARCHAR(50),

@PRODUCTID INT = NULL,
@PRODUCTNAME VARCHAR(150) = NULL,
@UNQBC VARCHAR(50) = NULL,
@CATEGORYID INT = NULL,
@UNITPRICE DECIMAL(18,2) = NULL,
@COSTPRICE DECIMAL(18,2) = NULL,
@QUANTITYINSTOCK INT = NULL,
@ISACTIVE BIT = NULL,

@CREATEDBY INT = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDBY INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- ✅ INSERT
        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Products
            (
                ProductName,
                UNQBC,
                CategoryId,
                UnitPrice,
                CostPrice,
                QuantityInStock,
                IsActive,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @PRODUCTNAME,
                @UNQBC,
                @CATEGORYID,
                @UNITPRICE,
                @COSTPRICE,
                ISNULL(@QUANTITYINSTOCK, 0),
                ISNULL(@ISACTIVE, 1),
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewProductId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                P.ProductId,
                P.ProductName,
                P.UNQBC,
                C.CategoryName,
                P.UnitPrice,
                P.CostPrice,
                P.QuantityInStock,
                P.IsActive,
                P.CreatedOn,
                P.CreatedBy,
                P.ModifiedAt,
                P.ModifiedBy
            FROM Products P
            LEFT JOIN ProductCategory C ON P.CategoryId = C.CategoryId
            WHERE P.IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                P.ProductId,
                P.ProductName,
                P.UNQBC,
                C.CategoryName,
                P.UnitPrice,
                P.CostPrice,
                P.QuantityInStock,
                P.IsActive,
                P.CreatedOn,
                P.CreatedBy,
                P.ModifiedAt,
                P.ModifiedBy
            FROM Products P
            LEFT JOIN ProductCategory C ON P.CategoryId = C.CategoryId
            WHERE P.ProductId = @PRODUCTID AND P.IsDeleted = 0;
        END

        -- ✅ 🔍 GET BY CATEGORY ID
        ELSE IF @FLAG = 'GETBYCATEGORYID'
        BEGIN
            SELECT 
                P.ProductId,
                P.ProductName,
                P.UNQBC,
                C.CategoryName,
                P.UnitPrice,
                P.CostPrice,
                P.QuantityInStock,
                P.IsActive,
                P.CreatedOn,
                P.CreatedBy,
                P.ModifiedAt,
                P.ModifiedBy
            FROM Products P
            LEFT JOIN ProductCategory C ON P.CategoryId = C.CategoryId
            WHERE P.CategoryId = @CATEGORYID AND P.IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Products
            SET 
                ProductName = ISNULL(@PRODUCTNAME, ProductName),
                UNQBC = ISNULL(@UNQBC, UNQBC),
                CategoryId = ISNULL(@CATEGORYID, CategoryId),
                UnitPrice = ISNULL(@UNITPRICE, UnitPrice),
                CostPrice = ISNULL(@COSTPRICE, CostPrice),
                QuantityInStock = ISNULL(@QUANTITYINSTOCK, QuantityInStock),
                IsActive = ISNULL(@ISACTIVE, IsActive),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE ProductId = @PRODUCTID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Products
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE ProductId = @PRODUCTID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_PRODUCTS.', 16, 1);
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

