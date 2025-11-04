USE SmartServeDB

CREATE TABLE Staff (
    StaffId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    DepartmentId INT NOT NULL,
    JoiningDate DATETIME NOT NULL,
    Salary DECIMAL(18,2) NULL,
    IsActive BIT DEFAULT 1 NOT NULL,
    Remarks TEXT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Staff_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId),
    CONSTRAINT FK_Staff_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Staff_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Staff_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

GO

USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_STAFF]
@FLAG VARCHAR(50),

@STAFFID INT = NULL,
@USERID INT = NULL,
@DEPARTMENTID INT = NULL,
@JOININGDATE DATETIME = NULL,
@SALARY DECIMAL(18,2) = NULL,
@REMARKS TEXT = NULL,
@ISACTIVE BIT = NULL,

@CREATEDBY INT = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDBY INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Staff
            (
                UserId,
                DepartmentId,
                JoiningDate,
                Salary,
                Remarks,
                IsActive,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @USERID,
                @DEPARTMENTID,
                @JOININGDATE,
                @SALARY,
                @REMARKS,
                ISNULL(@ISACTIVE, 1),
                GETDATE(),
                @CREATEDBY,
                0
            );

            SELECT SCOPE_IDENTITY() AS NewStaffId;
        END

        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                S.StaffId,
                S.UserId,
                U.UserName,
                U.UserEmail,
                S.DepartmentId,
                D.DepartmentName,
                S.JoiningDate,
                S.Salary,
                S.Remarks,
                S.IsActive,
                S.IsDeleted,
                S.CreatedOn,
                S.CreatedBy,
                S.ModifiedAt,
                S.ModifiedBy
            FROM Staff S
            LEFT JOIN Users U ON S.UserId = U.UserId
            LEFT JOIN Departments D ON S.DepartmentId = D.DepartmentId
            WHERE S.IsDeleted = 0;
        END

        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                S.StaffId,
                S.UserId,
                U.UserName,
                U.UserEmail,
                S.DepartmentId,
                D.DepartmentName,
                S.JoiningDate,
                S.Salary,
                S.Remarks,
                S.IsActive,
                S.IsDeleted,
                S.CreatedOn,
                S.CreatedBy,
                S.ModifiedAt,
                S.ModifiedBy
            FROM Staff S
            LEFT JOIN Users U ON S.UserId = U.UserId
            LEFT JOIN Departments D ON S.DepartmentId = D.DepartmentId
            WHERE S.StaffId = @STAFFID AND S.IsDeleted = 0;
        END

        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Staff
            SET 
                UserId = ISNULL(@USERID, UserId),
                DepartmentId = ISNULL(@DEPARTMENTID, DepartmentId),
                JoiningDate = ISNULL(@JOININGDATE, JoiningDate),
                Salary = ISNULL(@SALARY, Salary),
                Remarks = ISNULL(@REMARKS, Remarks),
                IsActive = ISNULL(@ISACTIVE, IsActive),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE StaffId = @STAFFID AND IsDeleted = 0;
        END

        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Staff
            SET 
                IsDeleted = 1,
                IsActive = 0,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE StaffId = @STAFFID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_STAFF.', 16, 1);
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
