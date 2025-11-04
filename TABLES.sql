USE SmartServeDB
GO 
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(80) NOT NULL,
    UserEmail VARCHAR(80) UNIQUE NOT NULL,
    PasswordHash VARCHAR(128) NOT NULL,
    Role VARCHAR(20) CHECK (Role IN ('Admin','Customer','Technician','Staff')),
    IsActive BIT DEFAULT 1,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT(0) NOT NULL,

    CONSTRAINT CHK_UserName_Length CHECK (LEN(UserName) BETWEEN 3 AND 30),
    CONSTRAINT CHK_UserEmail_Format CHECK (
        UserEmail LIKE '_%@_%._%' 
        AND UserEmail NOT LIKE '%@%@%' 
        AND UserEmail NOT LIKE '% %'
    ),

    CONSTRAINT FK_Users_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Users_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);




GO 

CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,     
    UserId INT NOT NULL,                          
    Name VARCHAR(80) NOT NULL,
    Email VARCHAR(80) NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    AddressId INT NULL,
    ProfileImage VARCHAR(255) NULL,               

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,              

    CONSTRAINT FK_Customers_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_Address FOREIGN KEY (AddressId) REFERENCES Addresses(AddressId),
    CONSTRAINT FK_Customers_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Customers_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId),
    CONSTRAINT CHK_Customer_Phone_Format CHECK (PhoneNumber NOT LIKE '%[^0-9+]%')
);

GO

CREATE TABLE Addresses (
    AddressId INT IDENTITY(1,1) PRIMARY KEY,
    AddressLine VARCHAR(255) NOT NULL,
    Landmark VARCHAR(100) NULL,
    City VARCHAR(80) NOT NULL,
    State VARCHAR(80) NOT NULL,
    Pincode VARCHAR(10) NOT NULL,
    Country VARCHAR(50) NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,                             
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Address_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Address_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Address_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId),
    CONSTRAINT CHK_Pincode_Format CHECK (Pincode NOT LIKE '%[^0-9]%' AND LEN(Pincode) BETWEEN 5 AND 10)
);

GO 
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

CREATE TABLE Technicians (
    TechnicianId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    Experience VARCHAR(100) NULL,
    Rating DECIMAL(3,2) NULL,
    IsAvailable BIT DEFAULT 1 NOT NULL,
    Salary DECIMAL(18,2) NULL,
    JoinedDate DATE DEFAULT GETDATE(),

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Technicians_User FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Technicians_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Technicians_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Technicians_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);
 GO

CREATE TABLE TechnicianSpecialization (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TechnicianId INT NOT NULL,
    SpecializationName VARCHAR(100) NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_TechSpec_Technician FOREIGN KEY (TechnicianId) REFERENCES Technicians(TechnicianId),
    CONSTRAINT FK_TechSpec_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_TechSpec_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_TechSpec_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

GO

CREATE TABLE TechnicianEducation (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TechnicianId INT NOT NULL,
    Qualification VARCHAR(150) NOT NULL,     
    Institution VARCHAR(150) NULL,            
    YearOfPassing INT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_TechEdu_Technician FOREIGN KEY (TechnicianId) REFERENCES Technicians(TechnicianId),
    CONSTRAINT FK_TechEdu_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_TechEdu_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_TechEdu_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);

GO

CREATE TABLE Vehicles (
    VehicleId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,                        
    VehicleNumber VARCHAR(20) NOT NULL,             
    Model VARCHAR(100) NOT NULL,                    
    [Year] INT NULL,                                
    Description VARCHAR(255) NULL,                 
    FuelType VARCHAR(20) CHECK (FuelType IN ('Petrol', 'Diesel', 'Electric', 'Hybrid')),
    Brand VARCHAR(50) NULL,            

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Vehicles_Customer FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT FK_Vehicles_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Vehicles_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Vehicles_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId),
    CONSTRAINT UQ_Vehicles_VehicleNumber UNIQUE (VehicleNumber)  -- Prevent duplicates
);

GO

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

GO

CREATE TABLE Billing (
    BillingId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    AppointmentId INT NULL,
    BillDate DATETIME DEFAULT GETDATE() NOT NULL,
    InvoiceNumber VARCHAR(50) UNIQUE NOT NULL,

    TotalAmount DECIMAL(18,2) NOT NULL CHECK (TotalAmount >= 0),
    Discount DECIMAL(18,2) DEFAULT 0 CHECK (Discount >= 0),
    GrandTotal AS (TotalAmount - Discount) PERSISTED,

    PaymentMode INT DEFAULT 3 NOT NULL,
    PaymentStatus INT DEFAULT 3 NOT NULL,

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

 GO

 CREATE TABLE ProductCategory (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    
    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_ProductCategory_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_ProductCategory_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_ProductCategory_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);
GO

CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    UNQBC VARCHAR(50) UNIQUE NOT NULL,
    CategoryId INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    CostPrice DECIMAL(18,2) NOT NULL,
    QuantityInStock INT DEFAULT 0 CHECK (QuantityInStock >= 0),
    IsActive BIT DEFAULT 1 NOT NULL,

    CreatedOn DATETIME DEFAULT GETDATE() NOT NULL,
    CreatedBy INT NULL,
    ModifiedAt DATETIME NULL,
    ModifiedBy INT NULL,
    DeletedOn DATETIME NULL,
    DeletedBy INT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,

    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryId) REFERENCES ProductCategory(CategoryId),
    CONSTRAINT FK_Products_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Products_ModifiedBy FOREIGN KEY (ModifiedBy) REFERENCES Users(UserId),
    CONSTRAINT FK_Products_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES Users(UserId)
);    
 GO

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

GO

CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    BillingId INT NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE() NOT NULL,

    PaymentMode INT NOT NULL CHECK (PaymentMode IN (1, 2)),  
    -- 1 = RazorPay, 2 = Cash

    AmountPaid DECIMAL(18,2) NOT NULL CHECK (AmountPaid >= 0),
    TransactionId VARCHAR(100) NULL,  -- Used only for RazorPay

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
  GO

  CREATE TABLE ServiceJobs (
    ServiceJobId INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentId INT NOT NULL,                     
    TechnicianId INT NOT NULL,                    
    StartTime DATETIME NULL,
    EndTime DATETIME NULL,
    WorkDescription TEXT NULL,

    Status INT DEFAULT 1 NOT NULL,
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

GO

CREATE TABLE Notifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,

    Title VARCHAR(150) NOT NULL,
    Message TEXT NOT NULL,

    NotificationType INT NOT NULL DEFAULT 1, 
    RelatedId INT NULL,                       

    NotificationStatus INT DEFAULT 0 NOT NULL, 
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
