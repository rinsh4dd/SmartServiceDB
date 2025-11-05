USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_PRODUCTCATEGORY]
@FLAG VARCHAR(50),

@CATEGORYID INT = NULL,
@CATEGORYNAME VARCHAR(100) = NULL,

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
            INSERT INTO ProductCategory
            (
                CategoryName,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @CATEGORYNAME,
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewCategoryId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                CategoryId,
                CategoryName,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy
            FROM ProductCategory
            WHERE IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                CategoryId,
                CategoryName,
                CreatedOn,
                CreatedBy,
                ModifiedAt,
                ModifiedBy
            FROM ProductCategory
            WHERE CategoryId = @CATEGORYID AND IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE ProductCategory
            SET 
                CategoryName = ISNULL(@CATEGORYNAME, CategoryName),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE CategoryId = @CATEGORYID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE ProductCategory
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE CategoryId = @CATEGORYID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_PRODUCTCATEGORY.', 16, 1);
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
