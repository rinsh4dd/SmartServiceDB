USE SmartServeDB

 CREATE TABLE Departments (
    DepartmentId INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Description TEXT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,
    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Departments_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Departments_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Departments_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

GO 
CREATE PROCEDURE [dbo].[SP_DEPARTMENTS]
@FLAG VARCHAR(50) = NULL,

@DEPARTMENTID INT = NULL,
@DEPARTMENTNAME VARCHAR(100) = NULL,
@DESCRIPTION TEXT = NULL,
@ISACTIVE BIT = NULL,

@CREATEDON DATETIME = NULL,
@CREATEDBY INT = NULL,
@MODIFIEDAT DATETIME = NULL,
@MODIFIEDBY INT = NULL,
@DELETEDON DATETIME = NULL,
@DELETEDBY INT = NULL,
@ISDELETED BIT = NULL

AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @FLAG = 'INSERT'
        BEGIN
            INSERT INTO Departments
            (
                DepartmentName,
                Description,
                IsActive,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            VALUES
            (
                @DEPARTMENTNAME,
                @DESCRIPTION,
                ISNULL(@ISACTIVE, 1),
                ISNULL(@CREATEDON, GETDATE()),
                @CREATEDBY,
                0
            );

			    SELECT SCOPE_IDENTITY() AS NewDepartmentId;
        END

		        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                D.DepartmentId,
                D.DepartmentName,
                D.Description,
                D.IsActive,
                D.CreatedOn,
                U1.UserName AS CreatedByUser,
                D.ModifiedAt,
                U2.UserName AS ModifiedByUser,
                D.IsDeleted
            FROM Departments D
            LEFT JOIN Users U1 ON D.CreatedBy = U1.UserId
            LEFT JOIN Users U2 ON D.ModifiedBy = U2.UserId
            WHERE D.IsDeleted = 0
            ORDER BY D.DepartmentName ASC;
        END

		        ELSE IF @FLAG = 'GETBYID'
        BEGIN
            SELECT 
                D.DepartmentId,
                D.DepartmentName,
                D.Description,
                D.IsActive,
                D.CreatedOn,
                D.CreatedBy,
                D.ModifiedAt,
                D.ModifiedBy,
                D.DeletedOn,
                D.DeletedBy,
                D.IsDeleted
            FROM Departments D
            WHERE D.DepartmentId = @DEPARTMENTID AND D.IsDeleted = 0;
        END

		        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Departments
            SET
                DepartmentName = ISNULL(@DEPARTMENTNAME, DepartmentName),
                Description = ISNULL(@DESCRIPTION, Description),
                IsActive = ISNULL(@ISACTIVE, IsActive),
                ModifiedAt = ISNULL(@MODIFIEDAT, GETDATE()),
                ModifiedBy = @MODIFIEDBY
            WHERE DepartmentId = @DEPARTMENTID AND IsDeleted = 0;
        END

		
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Departments
            SET
                IsDeleted = 1,
                DeletedOn = ISNULL(@DELETEDON, GETDATE()),
                DeletedBy = @DELETEDBY,
                IsActive = 0
            WHERE DepartmentId = @DEPARTMENTID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_DEPARTMENTS.', 16, 1);
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