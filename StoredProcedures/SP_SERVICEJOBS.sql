CREATE TABLE ServiceJobs (
    ServiceJobId INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentId INT NOT NULL,                     
    TechnicianId INT NOT NULL,                    
    StartTime DATETIME NULL,
    EndTime DATETIME NULL,
    WorkDescription TEXT NULL,
    Status INT DEFAULT 1 NOT NULL,  -- 1=Assigned, 2=InProgress, 3=Completed, 4=Cancelled
    Feedback TEXT NULL,
    BillingId INT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_ServiceJob_Appointment FOREIGN KEY (AppointmentId) REFERENCES Appointments(AppointmentId),
    CONSTRAINT FK_ServiceJob_Technician FOREIGN KEY (TechnicianId) REFERENCES Technicians(TechnicianId),
    CONSTRAINT FK_ServiceJob_Billing FOREIGN KEY (BillingId) REFERENCES Billing(BillingId),
    CONSTRAINT CHK_ServiceJob_Status CHECK (Status BETWEEN 1 AND 4)
);


