CREATE TABLE BillingItems (
    BillingItemId INT IDENTITY(1,1) PRIMARY KEY,
    BillingId INT NOT NULL,
    ProductId INT NULL,
    Quantity INT DEFAULT 1 CHECK (Quantity > 0),
    LabourCharge DECIMAL(18,2) DEFAULT 0 CHECK (LabourCharge >= 0),
    UnitPrice DECIMAL(18,2) DEFAULT 0 CHECK (UnitPrice >= 0),
    Discount DECIMAL(18,2) DEFAULT 0 CHECK (Discount >= 0),
    Total AS ((Quantity * UnitPrice) + LabourCharge - Discount) PERSISTED,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_BillingItems_Billing FOREIGN KEY (BillingId) REFERENCES Billing(BillingId),
    CONSTRAINT FK_BillingItems_Product FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT FK_BillingItems_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_BillingItems_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_BillingItems_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);


USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_BILLINGITEMS]
@FLAG VARCHAR(50),

@BILLINGITEMID INT = NULL,
@BILLINGID INT = NULL,
@PRODUCTID INT = NULL,
@QUANTITY INT = NULL,
@LABOURCHARGE DECIMAL(18,2) = NULL,
@UNITPRICE DECIMAL(18,2) = NULL,
@DISCOUNT DECIMAL(18,2) = NULL,

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
            INSERT INTO BillingItems
            (
                BillingId,
                ProductId,
                Quantity,
                LabourCharge,
                UnitPrice,
                Discount,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @BILLINGID,
                @PRODUCTID,
                ISNULL(@QUANTITY, 1),
                ISNULL(@LABOURCHARGE, 0),
                ISNULL(@UNITPRICE, 0),
                ISNULL(@DISCOUNT, 0),
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewBillingItemId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                BI.BillingItemId,
                BI.BillingId,
                B.InvoiceNumber,
                BI.ProductId,
                P.ProductName,
                BI.Quantity,
                BI.LabourCharge,
                BI.UnitPrice,
                BI.Discount,
                BI.Total,
                BI.CreatedOn,
                BI.CreatedBy,
                BI.ModifiedAt,
                BI.ModifiedBy
            FROM BillingItems BI
            LEFT JOIN Billing B ON BI.BillingId = B.BillingId
            LEFT JOIN Products P ON BI.ProductId = P.ProductId
            WHERE BI.IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                BI.BillingItemId,
                BI.BillingId,
                B.InvoiceNumber,
                BI.ProductId,
                P.ProductName,
                BI.Quantity,
                BI.LabourCharge,
                BI.UnitPrice,
                BI.Discount,
                BI.Total,
                BI.CreatedOn,
                BI.CreatedBy,
                BI.ModifiedAt,
                BI.ModifiedBy
            FROM BillingItems BI
            LEFT JOIN Billing B ON BI.BillingId = B.BillingId
            LEFT JOIN Products P ON BI.ProductId = P.ProductId
            WHERE BI.BillingItemId = @BILLINGITEMID AND BI.IsDeleted = 0;
        END

        -- ✅ GET BY BILLING ID
        ELSE IF @FLAG = 'GETBYBILLINGID'
        BEGIN
            SELECT 
                BI.BillingItemId,
                BI.BillingId,
                BI.ProductId,
                P.ProductName,
                BI.Quantity,
                BI.LabourCharge,
                BI.UnitPrice,
                BI.Discount,
                BI.Total
            FROM BillingItems BI
            LEFT JOIN Products P ON BI.ProductId = P.ProductId
            WHERE BI.BillingId = @BILLINGID AND BI.IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE BillingItems
            SET 
                ProductId = ISNULL(@PRODUCTID, ProductId),
                Quantity = ISNULL(@QUANTITY, Quantity),
                LabourCharge = ISNULL(@LABOURCHARGE, LabourCharge),
                UnitPrice = ISNULL(@UNITPRICE, UnitPrice),
                Discount = ISNULL(@DISCOUNT, Discount),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE BillingItemId = @BILLINGITEMID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE BillingItems
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE BillingItemId = @BILLINGITEMID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_BILLINGITEMS.', 16, 1);
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
