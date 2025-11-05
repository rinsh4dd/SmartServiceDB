USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_VEHICLES]
@FLAG VARCHAR(50),

@VEHICLEID INT = NULL,
@CUSTOMERID INT = NULL,
@VEHICLENUMBER VARCHAR(20) = NULL,
@MODEL VARCHAR(100) = NULL,
@YEAR INT = NULL,
@DESCRIPTION VARCHAR(255) = NULL,
@FUELTYPE VARCHAR(20) = NULL,
@BRAND VARCHAR(50) = NULL,

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
            INSERT INTO Vehicles
            (
                CustomerId,
                VehicleNumber,
                Model,
                [Year],
                Description,
                FuelType,
                Brand,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @CUSTOMERID,
                @VEHICLENUMBER,
                @MODEL,
                @YEAR,
                @DESCRIPTION,
                @FUELTYPE,
                @BRAND,
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewVehicleId;
        END

        -- ✅ GET ALL
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                V.VehicleId,
                V.CustomerId,
                C.Name AS CustomerName,
                V.VehicleNumber,
                V.Model,
                V.[Year],
                V.Description,
                V.FuelType,
                V.Brand,
                V.CreatedOn,
                V.CreatedBy,
                V.ModifiedAt,
                V.ModifiedBy,
                V.IsDeleted
            FROM Vehicles V
            LEFT JOIN Customers C ON V.CustomerId = C.CustomerId
            WHERE V.IsDeleted = 0;
        END

        -- ✅ GET BY ID
        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                V.VehicleId,
                V.CustomerId,
                C.Name AS CustomerName,
                V.VehicleNumber,
                V.Model,
                V.[Year],
                V.Description,
                V.FuelType,
                V.Brand,
                V.CreatedOn,
                V.CreatedBy,
                V.ModifiedAt,
                V.ModifiedBy,
                V.IsDeleted
            FROM Vehicles V
            LEFT JOIN Customers C ON V.CustomerId = C.CustomerId
            WHERE V.VehicleId = @VEHICLEID AND V.IsDeleted = 0;
        END

        -- ✅ UPDATE
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Vehicles
            SET 
                CustomerId = ISNULL(@CUSTOMERID, CustomerId),
                VehicleNumber = ISNULL(@VEHICLENUMBER, VehicleNumber),
                Model = ISNULL(@MODEL, Model),
                [Year] = ISNULL(@YEAR, [Year]),
                Description = ISNULL(@DESCRIPTION, Description),
                FuelType = ISNULL(@FUELTYPE, FuelType),
                Brand = ISNULL(@BRAND, Brand),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE VehicleId = @VEHICLEID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Vehicles
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE VehicleId = @VEHICLEID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_VEHICLES.', 16, 1);
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






EXEC SP_VEHICLES
    @FLAG = 'INSERT',
    @CUSTOMERID = 8,
    @VEHICLENUMBER = 'KL07AB1234',
    @MODEL = 'Swift VXI',
    @YEAR = 2018,
    @DESCRIPTION = 'Customer’s daily-use car',
    @FUELTYPE = 'Petrol',
    @BRAND = 'Maruti'

EXEC SP_VEHICLES
    @FLAG = 'UPDATE',
    @VEHICLEID = 3,
    @MODEL = 'Swift ZXI Plus'

EXEC SP_VEHICLES @FLAG = 'GETALL';

EXEC SP_VEHICLES @FLAG = 'GETBYID', @VEHICLEID = 3

EXEC SP_VEHICLES 
    @FLAG = 'DELETE',
    @VEHICLEID = 2,
    @DELETEDBY = 1;
