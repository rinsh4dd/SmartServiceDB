CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    BillingId INT NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE() NOT NULL,
    PaymentMode INT NOT NULL CHECK (PaymentMode IN (1, 2)),  
    -- 1 = RazorPay, 2 = Cash

    AmountPaid DECIMAL(18,2) NOT NULL CHECK (AmountPaid >= 0),
    TransactionId VARCHAR(100) NULL,  -- RazorPay reference
    PaymentStatus INT NOT NULL CHECK (PaymentStatus IN (1, 2, 3)) DEFAULT 1,
    -- 1 = Pending, 2 = Success, 3 = Failed

    Remarks TEXT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Payments_Billing FOREIGN KEY (BillingId) REFERENCES Billing(BillingId),
    CONSTRAINT FK_Payments_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Payments_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Payments_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);


USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_PAYMENTS]
@FLAG VARCHAR(50),

@PAYMENTID INT = NULL,
@BILLINGID INT = NULL,
@PAYMENTDATE DATETIME = NULL,
@PAYMENTMODE INT = NULL,       -- 1=RazorPay, 2=Cash
@AMOUNTPAID DECIMAL(18,2) = NULL,
@TRANSACTIONID VARCHAR(100) = NULL,
@PAYMENTSTATUS INT = NULL,     -- 1=Pending, 2=Success, 3=Failed
@REMARKS TEXT = NULL,

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
            INSERT INTO Payments
            (
                BillingId,
                PaymentDate,
                PaymentMode,
                AmountPaid,
                TransactionId,
                PaymentStatus,
                Remarks,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @BILLINGID,
                ISNULL(@PAYMENTDATE, GETDATE()),
                ISNULL(@PAYMENTMODE, 2),
                @AMOUNTPAID,
                @TRANSACTIONID,
                ISNULL(@PAYMENTSTATUS, 1),
                @REMARKS,
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewPaymentId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                P.PaymentId,
                P.BillingId,
                B.InvoiceNumber,
                P.PaymentDate,
                P.PaymentMode,
                CASE P.PaymentMode
                    WHEN 1 THEN 'RazorPay'
                    WHEN 2 THEN 'Cash'
                END AS PaymentModeName,
                P.AmountPaid,
                P.TransactionId,
                P.PaymentStatus,
                CASE P.PaymentStatus
                    WHEN 1 THEN 'Pending'
                    WHEN 2 THEN 'Success'
                    WHEN 3 THEN 'Failed'
                END AS PaymentStatusName,
                P.Remarks,
                P.CreatedOn,
                P.CreatedBy,
                P.ModifiedAt,
                P.ModifiedBy
            FROM Payments P
            LEFT JOIN Billing B ON P.BillingId = B.BillingId
            WHERE P.IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                P.PaymentId,
                P.BillingId,
                B.InvoiceNumber,
                P.PaymentDate,
                P.PaymentMode,
                CASE P.PaymentMode
                    WHEN 1 THEN 'RazorPay'
                    WHEN 2 THEN 'Cash'
                END AS PaymentModeName,
                P.AmountPaid,
                P.TransactionId,
                P.PaymentStatus,
                CASE P.PaymentStatus
                    WHEN 1 THEN 'Pending'
                    WHEN 2 THEN 'Success'
                    WHEN 3 THEN 'Failed'
                END AS PaymentStatusName,
                P.Remarks,
                P.CreatedOn,
                P.CreatedBy,
                P.ModifiedAt,
                P.ModifiedBy
            FROM Payments P
            LEFT JOIN Billing B ON P.BillingId = B.BillingId
            WHERE P.PaymentId = @PAYMENTID AND P.IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Payments
            SET 
                PaymentMode = ISNULL(@PAYMENTMODE, PaymentMode),
                AmountPaid = ISNULL(@AMOUNTPAID, AmountPaid),
                TransactionId = ISNULL(@TRANSACTIONID, TransactionId),
                PaymentStatus = ISNULL(@PAYMENTSTATUS, PaymentStatus),
                Remarks = ISNULL(@REMARKS, Remarks),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE PaymentId = @PAYMENTID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Payments
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE PaymentId = @PAYMENTID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_PAYMENTS.', 16, 1);
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





-- 💳 INSERT (Online Payment - RazorPay)
EXEC SP_PAYMENTS 
    @FLAG = 'INSERT',
    @BILLINGID = 1,
    @PAYMENTMODE = 1,
    @AMOUNTPAID = 3500,
    @TRANSACTIONID = 'RAZOR-TRX-12345',
    @PAYMENTSTATUS = 2,
    @REMARKS = 'Full payment via RazorPay'

-- 💵 INSERT (Cash Payment)
EXEC SP_PAYMENTS 
    @FLAG = 'INSERT',
    @BILLINGID = 2,
    @PAYMENTMODE = 2,
    @AMOUNTPAID = 2200,
    @PAYMENTSTATUS = 2,
    @REMARKS = 'Cash received at counter',
    @CREATEDBY = 1;

-- 📋 GET ALL
EXEC SP_PAYMENTS @FLAG = 'GETALL';

-- 🔍 GET BY ID
EXEC SP_PAYMENTS @FLAG = 'GETBYID', @PAYMENTID = 1;

-- 🔄 UPDATE PAYMENT STATUS
EXEC SP_PAYMENTS 
    @FLAG = 'UPDATE',
    @PAYMENTID = 1,
    @PAYMENTSTATUS = 2,
    @MODIFIEDBY = 1;

-- ❌ DELETE
EXEC SP_PAYMENTS 
    @FLAG = 'DELETE',
    @PAYMENTID = 2,
    @DELETEDBY = 1;
