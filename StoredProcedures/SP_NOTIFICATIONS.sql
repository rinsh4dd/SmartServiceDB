CREATE TABLE Notifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Message TEXT NOT NULL,
    NotificationType INT NOT NULL DEFAULT 1,   -- 1=System, 2=Job, 3=Payment, 4=Reminder, 5=General
    RelatedId INT NULL,                        -- Optional: links to Appointment, Job, or Billing
    NotificationStatus INT DEFAULT 0 NOT NULL, -- 0=Unread, 1=Read
    ReadOn DATETIME NULL,
    SentOn DATETIME DEFAULT GETDATE() NOT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Notifications_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CHK_Notifications_NotificationType CHECK (NotificationType BETWEEN 1 AND 5),
    CONSTRAINT CHK_Notifications_Status CHECK (NotificationStatus IN (0,1))
);




USE SmartServeDB
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_NOTIFICATIONS]
@FLAG VARCHAR(50),

@NOTIFICATIONID INT = NULL,
@USERID INT = NULL,
@TITLE VARCHAR(150) = NULL,
@MESSAGE TEXT = NULL,
@NOTIFICATIONTYPE INT = NULL,
@RELATEDID INT = NULL,
@NOTIFICATIONSTATUS INT = NULL,
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
            INSERT INTO Notifications
            (
                UserId,
                Title,
                Message,
                NotificationType,
                RelatedId,
                NotificationStatus,
                SentOn,
                CreatedOn,
                CreatedBy,
                IsDeleted,
                IsActive
            )
            VALUES
            (
                @USERID,
                @TITLE,
                @MESSAGE,
                ISNULL(@NOTIFICATIONTYPE, 1),
                @RELATEDID,
                0,  -- Unread by default
                GETDATE(),
                GETDATE(),
                @CREATEDBY,
                0,
                ISNULL(@ISACTIVE, 1)
            );

            SELECT SCOPE_IDENTITY() AS NewNotificationId;
        END

        -- ✅ GET ALL (Active)
        ELSE IF @FLAG = 'GETALL'
        BEGIN
            SELECT 
                N.NotificationId,
                N.UserId,
                U.UserName,
                N.Title,
                N.Message,
                N.NotificationType,
                CASE N.NotificationType
                    WHEN 1 THEN 'System'
                    WHEN 2 THEN 'Job'
                    WHEN 3 THEN 'Payment'
                    WHEN 4 THEN 'Reminder'
                    WHEN 5 THEN 'General'
                END AS TypeName,
                N.RelatedId,
                N.NotificationStatus,
                CASE N.NotificationStatus
                    WHEN 0 THEN 'Unread'
                    WHEN 1 THEN 'Read'
                END AS StatusText,
                N.SentOn,
                N.ReadOn,
                N.IsActive
            FROM Notifications N
            LEFT JOIN Users U ON N.UserId = U.UserId
            WHERE N.IsDeleted = 0 AND N.IsActive = 1
            ORDER BY N.SentOn DESC;
        END

        -- ✅ GET BY USER
        ELSE IF @FLAG = 'GETBYUSER'
        BEGIN
            SELECT 
                N.NotificationId,
                N.Title,
                N.Message,
                N.NotificationType,
                N.RelatedId,
                N.NotificationStatus,
                N.SentOn,
                N.ReadOn
            FROM Notifications N
            WHERE N.UserId = @USERID AND N.IsDeleted = 0
            ORDER BY N.SentOn DESC;
        END

        -- ✅ MARK AS READ
        ELSE IF @FLAG = 'MARKREAD'
        BEGIN
            UPDATE Notifications
            SET 
                NotificationStatus = 1,
                ReadOn = GETDATE(),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE NotificationId = @NOTIFICATIONID AND IsDeleted = 0;
        END

        -- ✅ UPDATE (Message / Title)
        ELSE IF @FLAG = 'UPDATE'
        BEGIN
            UPDATE Notifications
            SET 
                Title = ISNULL(@TITLE, Title),
                Message = ISNULL(@MESSAGE, Message),
                NotificationType = ISNULL(@NOTIFICATIONTYPE, NotificationType),
                IsActive = ISNULL(@ISACTIVE, IsActive),
                ModifiedAt = GETDATE(),
                ModifiedBy = @MODIFIEDBY
            WHERE NotificationId = @NOTIFICATIONID AND IsDeleted = 0;
        END

        -- ✅ DELETE (Soft Delete)
        ELSE IF @FLAG = 'DELETE'
        BEGIN
            UPDATE Notifications
            SET 
                IsDeleted = 1,
                DeletedOn = GETDATE(),
                DeletedBy = @DELETEDBY
            WHERE NotificationId = @NOTIFICATIONID AND IsDeleted = 0;
        END

        ELSE
        BEGIN
            RAISERROR('Invalid FLAG provided to SP_NOTIFICATIONS.', 16, 1);
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
EXEC SP_NOTIFICATIONS 
    @FLAG = 'INSERT',
    @USERID = 3,
    @TITLE = 'Appointment Assigned',
    @MESSAGE = 'Your appointment #2 has been assigned to technician John.',
    @NOTIFICATIONTYPE = 2,
    @RELATEDID = 2,
    @CREATEDBY = 1;

-- 📋 GET ALL ACTIVE NOTIFICATIONS
EXEC SP_NOTIFICATIONS @FLAG = 'GETALL';

-- 🔍 GET USER-SPECIFIC NOTIFICATIONS
EXEC SP_NOTIFICATIONS 
    @FLAG = 'GETBYUSER',
    @USERID = 3;

-- ✅ MARK AS READ
EXEC SP_NOTIFICATIONS 
    @FLAG = 'MARKREAD',
    @NOTIFICATIONID = 1,
    @MODIFIEDBY = 3;

-- 🔄 UPDATE NOTIFICATION MESSAGE
EXEC SP_NOTIFICATIONS 
    @FLAG = 'UPDATE',
    @NOTIFICATIONID = 1,
    @MESSAGE = 'Your appointment #2 has been completed successfully.',
    @MODIFIEDBY = 1;

-- ❌ DELETE NOTIFICATION
EXEC SP_NOTIFICATIONS 
    @FLAG = 'DELETE',
    @NOTIFICATIONID = 1,
    @DE
