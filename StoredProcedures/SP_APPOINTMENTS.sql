CREATE TABLE Appointments (
    AppointmentId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    VehicleId INT NOT NULL,
    ServiceType VARCHAR(100) NOT NULL,
    AppointmentDate DATE NOT NULL,
    PreferredSlot VARCHAR(50) NOT NULL,
    TechnicianId INT NULL,
    Status VARCHAR(20)
        CHECK (Status IN ('Pending','Assigned','InProgress','Completed','Cancelled'))
        DEFAULT 'Pending',
    ProblemDescription TEXT NULL,
    Remarks TEXT NULL,
    AssignedOn DATETIME NULL,
    CancelledOn DATETIME NULL,
    CompletedOn DATETIME NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Appointments_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT FK_Appointments_Vehicle FOREIGN KEY (VehicleId) REFERENCES Vehicles(VehicleId),
    CONSTRAINT FK_Appointments_Technician FOREIGN KEY (TechnicianId) REFERENCES Technicians(TechnicianId),
    CONSTRAINT FK_Appointments_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Appointments_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Appointments_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);




USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_APPOINTMENTS]
@FLAG VARCHAR(50),

@APPOINTMENTID INT = NULL,
@CUSTOMERID INT = NULL,
@VEHICLEID INT = NULL,
@SERVICETYPE VARCHAR(100) = NULL,
@APPOINTMENTDATE DATE = NULL,
@PREFERREDSLOT VARCHAR(50) = NULL,
@TECHNICIANID INT = NULL,
@STATUS VARCHAR(20) = NULL,
@PROBLEMDESCRIPTION TEXT = NULL,
@REMARKS TEXT = NULL,

@CREATEDBY INT = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDBY INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Appointments
            (
                CustomerId,
                VehicleId,
                ServiceType,
                AppointmentDate,
                PreferredSlot,
                TechnicianId,
                Status,
                ProblemDescription,
                Remarks,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @CUSTOMERID,
                @VEHICLEID,
                @SERVICETYPE,
                @APPOINTMENTDATE,
                @PREFERREDSLOT,
                @TECHNICIANID,
                ISNULL(@STATUS, 'Pending'),
                @PROBLEMDESCRIPTION,
                @REMARKS,
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewAppointmentId;
        END

        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                A.AppointmentId,
                A.CustomerId,
                C.Name AS CustomerName,
                A.VehicleId,
                V.VehicleNumber,
                V.Model,
                A.ServiceType,
                A.AppointmentDate,
                A.PreferredSlot,
                A.TechnicianId,
                T.TechnicianId AS TechRef,
                U.UserName AS TechnicianName,
                A.Status,
                A.ProblemDescription,
                A.Remarks,
                A.CreatedOn,
                A.CreatedBy,
                A.ModifiedAt,
                A.ModifiedBy
            FROM Appointments A
            LEFT JOIN Customers C ON A.CustomerId = C.CustomerId
            LEFT JOIN Vehicles V ON A.VehicleId = V.VehicleId
            LEFT JOIN Technicians T ON A.TechnicianId = T.TechnicianId
            LEFT JOIN Users U ON T.UserId = U.UserId
            WHERE A.IsDeleted = 0;
        END

        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                A.AppointmentId,
                A.CustomerId,
                C.Name AS CustomerName,
                A.VehicleId,
                V.VehicleNumber,
                V.Model,
                A.ServiceType,
                A.AppointmentDate,
                A.PreferredSlot,
                A.TechnicianId,
                U.UserName AS TechnicianName,
                A.Status,
                A.ProblemDescription,
                A.Remarks,
                A.CreatedOn,
                A.CreatedBy,
                A.ModifiedAt,
                A.ModifiedBy
            FROM Appointments A
            LEFT JOIN Customers C ON A.CustomerId = C.CustomerId
            LEFT JOIN Vehicles V ON A.VehicleId = V.VehicleId
            LEFT JOIN Technicians T ON A.TechnicianId = T.TechnicianId
            LEFT JOIN Users U ON T.UserId = U.UserId
            WHERE A.AppointmentId = @APPOINTMENTID AND A.IsDeleted = 0;
        END

        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Appointments
            SET 
                ServiceType = ISNULL(@SERVICETYPE, ServiceType),
                AppointmentDate = ISNULL(@APPOINTMENTDATE, AppointmentDate),
                PreferredSlot = ISNULL(@PREFERREDSLOT, PreferredSlot),
                TechnicianId = ISNULL(@TECHNICIANID, TechnicianId),
                Status = ISNULL(@STATUS, Status),
                ProblemDescription = ISNULL(@PROBLEMDESCRIPTION, ProblemDescription),
                Remarks = ISNULL(@REMARKS, Remarks),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE AppointmentId = @APPOINTMENTID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Appointments
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE AppointmentId = @APPOINTMENTID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_APPOINTMENTS.', 16, 1);
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




-- ➕ INSERT
EXEC SP_APPOINTMENTS 
    @FLAG = 'INSERT',
    @CUSTOMERID = 8,
    @VEHICLEID = 3,
    @SERVICETYPE = 'Periodic Maintenance',
    @APPOINTMENTDATE = '2025-11-05',
    @PREFERREDSLOT = 'Morning',
    @TECHNICIANID = 1,
    @PROBLEMDESCRIPTION = 'Engine noise & oil leakage',
    @REMARKS = 'Urgent service request'

EXEC SP_APPOINTMENTS 
    @FLAG = 'UPDATE',
    @APPOINTMENTID = 2,
    @STATUS = 'COMPLETED',
    @TECHNICIANID = 1

EXEC SP_APPOINTMENTS @FLAG = 'GETALL';

EXEC SP_APPOINTMENTS @FLAG = 'GETBYID', @APPOINTMENTID = 1;

EXEC SP_APPOINTMENTS 
    @FLAG = 'DELETE',
    @APPOINTMENTID = 1,
    @DELETEDBY = 1;
