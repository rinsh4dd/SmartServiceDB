CREATE TABLE Billing (
    BillingId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    AppointmentId INT NULL,
    BillDate DATETIME DEFAULT GETDATE() NOT NULL,
    InvoiceNumber VARCHAR(50) UNIQUE NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL CHECK (TotalAmount >= 0),
    Discount DECIMAL(18,2) DEFAULT 0 CHECK (Discount >= 0),
    GrandTotal AS (TotalAmount - Discount) PERSISTED,
    PaymentMode INT DEFAULT 3 NOT NULL, -- e.g., 1=RazorPay, 2=Cash, 3=Other
    PaymentStatus INT DEFAULT 3 NOT NULL, -- 1=Pending, 2=Paid, 3=Failed
    Remarks NVARCHAR(500) NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Billing_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT FK_Billing_Appointment FOREIGN KEY (AppointmentId) REFERENCES Appointments(AppointmentId),
    CONSTRAINT CHK_Billing_PaymentMode CHECK (PaymentMode BETWEEN 1 AND 3),
    CONSTRAINT CHK_Billing_PaymentStatus CHECK (PaymentStatus BETWEEN 1 AND 3)
);

USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_BILLING]
@FLAG VARCHAR(50),

@BILLINGID INT = NULL,
@CUSTOMERID INT = NULL,
@APPOINTMENTID INT = NULL,
@INVOICENUMBER VARCHAR(50) = NULL,
@TOTALAMOUNT DECIMAL(18,2) = NULL,
@DISCOUNT DECIMAL(18,2) = NULL,
@PAYMENTMODE INT = NULL,
@PAYMENTSTATUS INT = NULL,
@REMARKS NVARCHAR(500) = NULL,

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
            INSERT INTO Billing
            (
                CustomerId,
                AppointmentId,
                BillDate,
                InvoiceNumber,
                TotalAmount,
                Discount,
                PaymentMode,
                PaymentStatus,
                Remarks,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @CUSTOMERID,
                @APPOINTMENTID,
                GETDATE(),
                @INVOICENUMBER,
                ISNULL(@TOTALAMOUNT, 0),
                ISNULL(@DISCOUNT, 0),
                ISNULL(@PAYMENTMODE, 1),
                ISNULL(@PAYMENTSTATUS, 1),
                @REMARKS,
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewBillingId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                B.BillingId,
                B.InvoiceNumber,
                B.BillDate,
                B.CustomerId,
                C.Name AS CustomerName,
                B.AppointmentId,
                B.TotalAmount,
                B.Discount,
                B.GrandTotal,
                B.PaymentMode,
                B.PaymentStatus,
                B.Remarks,
                B.CreatedOn,
                B.CreatedBy,
                B.ModifiedAt,
                B.ModifiedBy
            FROM Billing B
            LEFT JOIN Customers C ON B.CustomerId = C.CustomerId
            WHERE B.IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                B.BillingId,
                B.InvoiceNumber,
                B.BillDate,
                B.CustomerId,
                C.Name AS CustomerName,
                B.AppointmentId,
                B.TotalAmount,
                B.Discount,
                B.GrandTotal,
                B.PaymentMode,
                B.PaymentStatus,
                B.Remarks,
                B.CreatedOn,
                B.CreatedBy,
                B.ModifiedAt,
                B.ModifiedBy
            FROM Billing B
            LEFT JOIN Customers C ON B.CustomerId = C.CustomerId
            WHERE B.BillingId = @BILLINGID AND B.IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Billing
            SET 
                TotalAmount = ISNULL(@TOTALAMOUNT, TotalAmount),
                Discount = ISNULL(@DISCOUNT, Discount),
                PaymentMode = ISNULL(@PAYMENTMODE, PaymentMode),
                PaymentStatus = ISNULL(@PAYMENTSTATUS, PaymentStatus),
                Remarks = ISNULL(@REMARKS, Remarks),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE BillingId = @BILLINGID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Billing
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE BillingId = @BILLINGID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_BILLING.', 16, 1);
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
