--------------------------------------------------------
--                                                    --
-- Create a database, tables and insert data for them --
--                                                    --
--------------------------------------------------------


-- STEP 1: Create a PASTRY_SHOP database
CREATE DATABASE PASTRY_SHOP
GO

-- STEP 2: Use PASTRY_SHOP database
USE PASTRY_SHOP
GO

-- STEP 3: Create Customer table
CREATE TABLE Customer
(
	Customer_Phone	VARCHAR(10)		NOT NULL,
	Customer_Name	NVARCHAR(50)	NOT NULL,
	Point			INT				NOT NULL,
	
	PRIMARY KEY (Customer_Phone)
)
GO

-- STEP 4: Create Employee table
CREATE TABLE Employee
(
	Employee_ID			VARCHAR(8)		NOT NULL,
	Employee_Name		NVARCHAR(50)	NOT NULL,
	Employee_Phone		VARCHAR(10)		NOT NULL,
	Employee_Address	NVARCHAR(100),
	
	PRIMARY KEY (Employee_ID)
)
GO

-- STEP 5: Create Product table
CREATE TABLE Product
(
	Product_ID		VARCHAR(5)		NOT NULL,
	Product_Name	NVARCHAR(100)	NOT NULL,
	Price			INT				NOT NULL,
	
	PRIMARY KEY (Product_ID)
)
GO

-- STEP 6: Create Voucher table
CREATE TABLE Voucher
(
	Voucher_ID				VARCHAR(5)		NOT NULL,
	Voucher_Description		NVARCHAR(200),
	Discount				INT				NOT NULL,
	Required_Total_Revenue	INT				NOT NULL,
	Begin_Date				DATE			NOT NULL,
	End_Date				DATE			NOT NULL,
	Is_Require_Member		BIT				NOT NULL,
	
	PRIMARY KEY (Voucher_ID)
)
GO

-- STEP 7: Create Bill table
CREATE TABLE Bill
(
	Bill_ID				VARCHAR(10)		NOT NULL,
	
	Create_Date			DATE			NOT NULL,
	Create_Time			TIME			NOT NULL,
	
	Payment_Date		DATE,
	Payment_Time		TIME,
	
	Primary_Price		INT,
	Used_Point			INT,
	Final_Price			INT,
	Earned_Point		INT,
	
	Given_Money			INT,
	Excess_Money		INT,
	
	Employee_ID			VARCHAR(8)		NOT NULL,
	Voucher_ID			VARCHAR(5),
	Customer_Phone		VARCHAR(10),
	
	PRIMARY KEY (Bill_ID)
)
GO

-- STEP 8: Create Bill_Data table
CREATE TABLE Bill_Data
(
	Bill_ID			VARCHAR(10)		NOT NULL,
	Product_ID		VARCHAR(5)		NOT NULL,
	Product_Amount	INT				NOT NULL,
	Price			INT				NOT NULL,
	
	PRIMARY KEY (Bill_ID, Product_ID)
)
GO

-- STEP 9: Create foreign keys for Bill table
ALTER TABLE Bill
ADD CONSTRAINT FK_Employee_ID
FOREIGN KEY (Employee_ID)
REFERENCES Employee (Employee_ID);
--
ALTER TABLE Bill
ADD CONSTRAINT FK_Voucher_ID
FOREIGN KEY (Voucher_ID)
REFERENCES Voucher (Voucher_ID);
--
ALTER TABLE Bill
ADD CONSTRAINT FK_Customer_Phone
FOREIGN KEY (Customer_Phone)
REFERENCES Customer (Customer_Phone);
GO

-- STEP 10: Create foreign keys for Bill_Data table
ALTER TABLE Bill_Data
ADD CONSTRAINT FK_Bill_ID
FOREIGN KEY (Bill_ID)
REFERENCES Bill (Bill_ID);
--
ALTER TABLE Bill_Data
ADD CONSTRAINT FK_Product_ID
FOREIGN KEY (Product_ID)
REFERENCES Product (Product_ID);
GO

-- STEP 11: Trigger for Customer table
-- Assign: Dat
-- Format: SĐT 10 số
-- VD: 03xxxxxxxx
CREATE TRIGGER CheckCustomerOnInsert
ON Customer
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Customer_Phone NOT LIKE '[0-9][1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
            OR Point < 0
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 12: Trigger for Employee table
-- Assign: Phong
-- Format: EMPQN001, EMPQN002, EMPQN003,...
CREATE TRIGGER CheckEmployeeOnInsert
ON Employee
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Employee_ID NOT LIKE 'EMPQN[0-9][0-9][0-9]'
            OR Employee_Phone NOT LIKE '[0-9][1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 13: Trigger for Product table
-- Assign: Quan
-- Format: PD001, PD002, PD003,...
CREATE TRIGGER CheckProductOnInsert
ON Product
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Product_ID NOT LIKE 'PD[0-9][0-9][0-9]'
            OR Price <= 0
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 14: Trigger for Voucher table
-- Assign: Duy
-- Format: VC001, VC002, VC003,...
CREATE TRIGGER CheckVoucherOnInsert
ON Voucher
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Voucher_ID NOT LIKE 'VC[0-9][0-9][0-9]'
            OR (Begin_Date >= End_Date)
            OR Required_Total_Revenue < 0
            OR Discount <= 0
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 15: Trigger for Bill table
-- Assign: Khoa
-- Format: BILL000001, BILL000002, BILL000003,...
CREATE TRIGGER CheckBillOnInsert
ON Bill
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Bill_ID NOT LIKE 'BILL[0-9][0-9][0-9][0-9][0-9][0-9]'
            OR Employee_ID NOT LIKE 'EMPQN[0-9][0-9][0-9]'
            OR (Customer_Phone IS NOT NULL AND Customer_Phone NOT LIKE '[0-9][1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 16: Trigger for Bill_Data table
-- Assign: Phong
-- Format:
-- - BILL000001, BILL000002, BILL000003,...
-- - PD001, PD002, PD003,...
CREATE TRIGGER CheckBill_DataOnInsert
ON Bill_Data
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Inserted
        WHERE Product_Amount <= 0
            OR Price <= 0
    )
    BEGIN
        PRINT ('Error! Insertion canceled!')
        ROLLBACK TRANSACTION
    END
END
GO

-- STEP 17: Insert data for Customer table
-- Assign: Duy
-- Format: SĐT 10 số
-- VD: 03xxxxxxxx
INSERT INTO Customer (Customer_Phone, Customer_Name, Point)
VALUES
('0934567890', N'Nguyễn Thị Hương', 8),
('0978012345', N'Lê Văn Tuấn', 7),
('0912345678', N'Trần Thị Lan Anh', 9),
('0987654321', N'Phạm Minh Đức', 23),
('0905123456', N'Hoàng Thị Thu Hà', 67),
('0967890123', N'Vũ Minh Hưng', 98),
('0943210987', N'Đặng Thanh Trúc', 34),
('0923456789', N'Bùi Xuân Nam', 3),
('0956789012', N'Ngô Thị Hồng Nhung', 4),
('0984321765', N'Đỗ Quang Trung', 127)
GO

-- STEP 18: Insert data for Employee table
-- Assign: Dat
-- Format: EMPQN001, EMPQN002, EMPQN003,...
INSERT INTO Employee (Employee_ID, Employee_Name, Employee_Phone, Employee_Address)
VALUES
('EMPQN001', N'Đinh Quốc Chương', '0376166640', N'An Nhơn'),
('EMPQN002', N'Lê Minh Vương', '0367626640', N'Tây Sơn'),
('EMPQN003', N'Hồ Trọng Nghĩa', '0307636664', N'An Nhơn'),
('EMPQN004', N'Nguyễn Thị Thúy', '0376464660', N'Tây Sơn'),
('EMPQN005', N'Nguyễn Thị Đào', '0376464661', N'Bình Minh')

GO

-- STEP 19: Insert data for Product table
-- Assign: Dat
-- Format: PD001, PD002, PD003,...
INSERT INTO Product (Product_ID, Product_Name, Price)
VALUES
('PD001', N'Bánh macaron', 35000),
('PD002', N'Bánh tiramisu', 60000),
('PD003', N'Bánh mousse socola', 65000),
('PD004', N'Bánh red velvet', 40000),
('PD005', N'Bánh cupcake', 25000),
('PD006', N'Bánh bông lan trứng muối', 75000),
('PD007', N'Bánh cheesecake', 55000),
('PD008', N'Bánh tart trái cây', 90000),
('PD009', N'Bánh cookie socola', 110000),
('PD010', N'Bánh hạnh nhân caramel', 45000)
GO

-- STEP 20: Insert data for Voucher table
-- Assign: Duy
-- Format: VC001, VC002, VC003,...
INSERT INTO Voucher (Voucher_ID, Voucher_Description, Discount, Required_Total_Revenue, Begin_Date, End_Date, Is_Require_Member)
VALUES
('VC001', N'Mừng ngày khai trương, giảm 5% cho khách hàng đã chi > 0 đồng', 5, 0, '2023-06-01', '2023-06-10', 0),
('VC002', N'Mừng ngày khai trương, giảm 10% cho khách hàng đã chi > 0 đồng', 10, 0, '2023-06-01', '2023-06-10', 1),
('VC003', N'Mừng hè, giảm 10% cho khách đã chi > 100000 đồng', 10, 100000, '2023-06-11', '2023-08-31', 1),
('VC004', N'Mừng trung thu, giảm 15% cho khách đã chi > 200000 đồng', 15, 200000, '2023-06-11', '2023-08-31', 1),
('VC005', N'Mừng Quốc Khánh, giảm 20% cho khách đã chi > 500000 đồng', 20, 500000, '2023-06-11', '2023-08-31', 1)
GO

-- STEP 21: Insert data for Bill table
-- Assign: Quan
-- Format: BILL000001, BILL000002, BILL000003,...
INSERT INTO Bill (Bill_ID, Create_Date, Create_Time, Employee_ID, Customer_Phone)
VALUES
('BILL000001', '2023-06-01', '08:10:10', 'EMPQN001', NULL),
('BILL000002', '2023-06-01', '10:00:03', 'EMPQN001', '0934567890'),
('BILL000003', '2023-06-08', '15:00:14', 'EMPQN002', '0923456789'),
('BILL000004', '2023-06-08', '15:17:00', 'EMPQN002', '0984321765'),
('BILL000005', '2023-06-11', '10:17:00', 'EMPQN003', NULL),
('BILL000006', '2023-06-11', '12:47:00', 'EMPQN004', '0912345678'),
('BILL000007', '2023-06-12', '13:45:00', 'EMPQN004', NULL),
('BILL000008', '2023-06-19', '11:54:00', 'EMPQN002', '0978012345'),
('BILL000009', '2023-07-01', '12:19:00', 'EMPQN001', '0978012345'),
('BILL000010', '2023-07-01', '08:02:00', 'EMPQN004', '0956789012'),
('BILL000011', '2023-07-02', '09:30:00', 'EMPQN003', '0943210987'),
('BILL000012', '2023-07-05', '14:20:00', 'EMPQN001', NULL),
('BILL000013', '2023-07-07', '16:45:00', 'EMPQN004', '0987654321'),
('BILL000014', '2023-07-10', '11:10:00', 'EMPQN002', '0905123456'),
('BILL000015', '2023-07-12', '18:30:00', 'EMPQN003', NULL),
('BILL000016', '2023-07-15', '10:05:00', 'EMPQN001', '0967890123'),
('BILL000017', '2023-07-15', '15:40:00', 'EMPQN004', '0978012345'),
('BILL000018', '2023-07-16', '13:20:00', 'EMPQN002', '0984321765'),
('BILL000019', '2023-07-16', '17:55:00', 'EMPQN001', NULL),
('BILL000020', '2023-07-16', '19:45:00', 'EMPQN003', '0912345678'),
('BILL000021', '2023-07-17', '09:15:00', 'EMPQN004', NULL),
('BILL000022', '2023-07-18', '12:30:00', 'EMPQN001', '0934567890'),
('BILL000023', '2023-07-19', '14:45:00', 'EMPQN003', '0923456789'),
('BILL000024', '2023-07-20', '16:20:00', 'EMPQN002', '0984321765'),
('BILL000025', '2023-07-21', '11:05:00', 'EMPQN004', NULL),
('BILL000026', '2023-07-22', '13:40:00', 'EMPQN001', '0912345678'),
('BILL000027', '2023-07-23', '15:25:00', 'EMPQN003', '0943210987'),
('BILL000028', '2023-07-24', '10:50:00', 'EMPQN002', '0956789012'),
('BILL000029', '2023-07-25', '17:15:00', 'EMPQN001', '0978012345'),
('BILL000030', '2023-07-26', '19:00:00', 'EMPQN004', NULL),
('BILL000031', '2023-07-27', '09:57:00', 'EMPQN004', '0978012345')
GO

-- STEP 22: Insert data for Bill_Data table
-- Assign: Phong
-- Format:
-- - BILL000001, BILL000002, BILL000003,...
-- - PD001, PD002, PD003,...
INSERT INTO Bill_Data (Bill_ID, Product_ID, Product_Amount, Price)
VALUES
('BILL000001', 'PD001', 10, 35000),
('BILL000001', 'PD002', 5,  60000),
('BILL000001', 'PD005', 3,  25000),
('BILL000002', 'PD001', 2,  35000),
('BILL000002', 'PD006', 10, 75000),
('BILL000003', 'PD003', 4,  65000),
('BILL000003', 'PD007', 6,  55000),
('BILL000003', 'PD004', 6,  40000),
('BILL000004', 'PD002', 8,  60000),
('BILL000004', 'PD009', 2,  110000),
('BILL000004', 'PD010', 12, 45000),
('BILL000005', 'PD004', 15, 40000),
('BILL000005', 'PD008', 7,  90000),
('BILL000005', 'PD003', 2,  65000),
('BILL000006', 'PD001', 3,  35000),
('BILL000006', 'PD003', 4,  65000),
('BILL000006', 'PD010', 4,  45000),
('BILL000007', 'PD003', 6,  65000),
('BILL000007', 'PD006', 8,  75000),
('BILL000007', 'PD007', 7,  55000),
('BILL000008', 'PD002', 12, 60000),
('BILL000008', 'PD007', 3,  55000),
('BILL000008', 'PD001', 3,  35000),
('BILL000008', 'PD004', 6,  40000),
('BILL000009', 'PD001', 5,  35000),
('BILL000009', 'PD008', 9,  90000),
('BILL000010', 'PD005', 2,  25000),
('BILL000010', 'PD010', 11, 45000),
('BILL000011', 'PD004', 6,  40000),
('BILL000011', 'PD009', 4,  110000),
('BILL000012', 'PD002', 9,  60000),
('BILL000012', 'PD006', 5,  75000),
('BILL000013', 'PD003', 7,  65000),
('BILL000013', 'PD008', 2,  90000),
('BILL000014', 'PD001', 6,  35000),
('BILL000014', 'PD009', 3,  110000),
('BILL000015', 'PD005', 4,  25000),
('BILL000015', 'PD010', 8,  45000),
('BILL000016', 'PD004', 10, 40000),
('BILL000016', 'PD006', 6,  75000),
('BILL000017', 'PD003', 3,  65000),
('BILL000017', 'PD007', 9,  55000),
('BILL000018', 'PD002', 7,  60000),
('BILL000018', 'PD008', 34, 90000),
('BILL000018', 'PD004', 2,  40000),
('BILL000018', 'PD009', 12, 110000),
('BILL000018', 'PD005', 3,  25000),
('BILL000018', 'PD010', 22, 45000),
('BILL000019', 'PD001', 8,  35000),
('BILL000019', 'PD010', 2,  45000),
('BILL000020', 'PD005', 6,  25000),
('BILL000020', 'PD009', 7,  110000),
('BILL000021', 'PD004', 12, 40000),
('BILL000021', 'PD007', 4,  55000),
('BILL000021', 'PD003', 8,  65000),
('BILL000022', 'PD002', 4,  60000),
('BILL000022', 'PD006', 9,  75000),
('BILL000023', 'PD003', 8,  65000),
('BILL000023', 'PD008', 3,  90000),
('BILL000024', 'PD001', 3,  35000),
('BILL000024', 'PD009', 5,  110000),
('BILL000025', 'PD005', 9,  25000),
('BILL000025', 'PD010', 11, 45000),
('BILL000026', 'PD004', 5,  40000),
('BILL000026', 'PD006', 8,  75000),
('BILL000027', 'PD003', 9,  65000),
('BILL000027', 'PD007', 3,  55000),
('BILL000028', 'PD002', 2,  60000),
('BILL000028', 'PD008', 7,  90000),
('BILL000029', 'PD001', 4,  35000),
('BILL000029', 'PD009', 6,  110000),
('BILL000029', 'PD002', 8,  60000),
('BILL000029', 'PD004', 12, 40000),
('BILL000030', 'PD008', 3,  90000),
('BILL000030', 'PD005', 7,  25000),
('BILL000030', 'PD010', 4,  45000),
('BILL000031', 'PD002', 4,  60000),
('BILL000031', 'PD007', 1,  55000),
('BILL000031', 'PD003', 2,  65000)
GO


-- STEP 23: Create procedure for Customer table
CREATE OR ALTER PROCEDURE Update_Point_For_Customer(@Customer_Phone VARCHAR(10), @Used_Point INT, @Earned_Point INT)
AS
BEGIN
    DECLARE @Point INT = 0

    SELECT  @Point = c.Point
    FROM    Customer c
    WHERE   c.Customer_Phone = @Customer_Phone

    SET @Point = @Point - @Used_Point + @Earned_Point

    UPDATE  Customer
    SET     Point = @Point
    WHERE   Customer_Phone = @Customer_Phone
END
GO

-- STEP 24: Create procedure for Bill table
CREATE OR ALTER PROCEDURE Calculate_Bill(@Bill_ID VARCHAR(10))
AS
BEGIN
    -- Declare variables
    DECLARE @Primary_Price  INT         = 0
    DECLARE @Used_Point     INT         = 0
    DECLARE @Customer_Phone VARCHAR(10) = NULL
    DECLARE @Create_Date    DATE        = NULL
    DECLARE @Voucher_ID     VARCHAR(5)  = NULL
    DECLARE @Discount       INT         = 0
    DECLARE @Final_Price    INT         = 0
    DECLARE @Earned_Point   INT         = 0
	DECLARE @Customer_Revenue INT = 0


    -- Get @Primary_Price with @Bill_ID
    SELECT      @Primary_Price = SUM(db.Product_Amount * db.Price)
    FROM        Bill_Data db
    GROUP BY    db.Bill_ID
    HAVING      db.Bill_ID = @Bill_ID

    -- Get @Used_Point, @Customer_Phone, @Create_Date with @Bill_ID
    SELECT      @Used_Point     = ISNULL(c.Point, 0),
                @Customer_Phone = b.Customer_Phone,
                @Create_Date    = b.Create_Date
    FROM        Bill b LEFT JOIN Customer c ON b.Customer_Phone = c.Customer_Phone
    WHERE       b.Bill_ID = @Bill_ID

    IF @Used_Point > 50
        SET @Used_Point = 50
    
    IF @Primary_Price - @Used_Point * 1000 <= 0
        SET @Used_Point = @Primary_Price / 1000
	
	-- Tính tổng doanh thu của khách hàng trước hóa đơn này
    IF @Customer_Phone IS NOT NULL
	BEGIN
		SELECT @Customer_Revenue = ISNULL(SUM(Final_Price), 0)
		FROM Bill
		WHERE Customer_Phone = @Customer_Phone AND Final_Price IS NOT NULL AND Bill_ID <> @Bill_ID
	END

	-- Chọn voucher nếu doanh thu đủ điều kiện
	SELECT TOP 1
		@Voucher_ID = v.Voucher_ID,
		@Discount = v.Discount
	FROM Voucher v
	WHERE 
		@Create_Date BETWEEN v.Begin_Date AND v.End_Date
		AND v.Required_Total_Revenue <= @Customer_Revenue
		AND v.Is_Require_Member = CASE WHEN @Customer_Phone IS NULL THEN 0 ELSE 1 END
	ORDER BY v.Discount DESC
    
    -- Calculate @Final_Price
    SET @Final_Price = ((@Primary_Price - @Used_Point * 1000) * (100 - @Discount)) / 100
    
    -- Calculate @Earned_Point
    SET @Earned_Point = @Final_Price / 20000
    
    -- Update Point for Customer
    IF @Customer_Phone IS NOT NULL
    BEGIN
        SET @Earned_Point = @Final_Price / 20000
        EXEC Update_Point_For_Customer @Customer_Phone, @Used_Point, @Earned_Point
    END
    ELSE
        SET @Earned_Point = 0

    -- Update Bill with @Bill_ID
    UPDATE  Bill
    SET     Primary_Price   = @Primary_Price,
            Used_Point      = @Used_Point,
            Final_Price     = @Final_Price,
            Earned_Point    = @Earned_Point,
            Voucher_ID      = @Voucher_ID
    WHERE   Bill_ID = @Bill_ID
END
GO

-- STEP 25: Create procedure for payment
CREATE OR ALTER PROCEDURE Pay (
    @Bill_ID VARCHAR(10),
    @Given_Money INT,
    @FakeDate DATE = NULL,
    @FakeTime TIME = NULL
)
AS
BEGIN
    DECLARE @Final_Price INT = 0
    DECLARE @Excess_Money INT = 0

    SELECT @Final_Price = Final_Price
    FROM Bill
    WHERE Bill_ID = @Bill_ID

    IF @Final_Price IS NULL
    BEGIN
        EXEC Calculate_Bill @Bill_ID
        SELECT @Final_Price = Final_Price
        FROM Bill
        WHERE Bill_ID = @Bill_ID
    END

    IF @Final_Price > @Given_Money
    BEGIN
        PRINT ('Error! Given_Money must be greater or equal to Final_Price!')
        RETURN
    END

    SET @Excess_Money = @Given_Money - @Final_Price

    DECLARE @UseDate DATE = ISNULL(@FakeDate, CAST(GETDATE() AS DATE))
    DECLARE @UseTime TIME = ISNULL(@FakeTime, CAST(GETDATE() AS TIME))

    UPDATE Bill
    SET 
        Payment_Date = @UseDate,
        Payment_Time = @UseTime,
        Given_Money = @Given_Money,
        Excess_Money = @Excess_Money
    WHERE Bill_ID = @Bill_ID
END
GO
-- STEP 26: Execute Pay procedure for bills 
EXEC Pay 'BILL000001', 940000, '2025-07-13', '09:23:00'
EXEC Pay 'BILL000002', 981000, '2025-07-02', '17:41:00'
EXEC Pay 'BILL000003', 995000, '2025-07-26', '14:07:00'
EXEC Pay 'BILL000004', 1322000, '2025-07-08', '11:35:00'
EXEC Pay 'BILL000005', 1611000, '2025-07-17', '10:15:00'
EXEC Pay 'BILL000006', 679000, '2025-07-31', '16:02:00'
EXEC Pay 'BILL000007', 1626000, '2025-07-01', '08:45:00'
EXEC Pay 'BILL000008', 1229000, '2025-07-22', '09:12:00'
EXEC Pay 'BILL000009', 1000000, '2025-07-04', '13:50:00'
EXEC Pay 'BILL000010', 683000, '2025-07-10', '17:15:00'
EXEC Pay 'BILL000011', 767000, '2025-07-27', '10:30:00'
EXEC Pay 'BILL000012', 1166000, '2025-07-18', '15:45:00'
EXEC Pay 'BILL000013', 740000, '2025-07-03', '14:18:00'
EXEC Pay 'BILL000014', 667000, '2025-07-21', '09:39:00'
EXEC Pay 'BILL000015', 711000, '2025-07-05', '11:04:00'
EXEC Pay 'BILL000016', 891000, '2025-07-14', '08:30:00'
EXEC Pay 'BILL000017', 773000, '2025-07-28', '16:11:00'
EXEC Pay 'BILL000018', 4967000, '2025-07-09', '12:55:00'
EXEC Pay 'BILL000019', 621000, '2025-07-24', '13:22:00'
EXEC Pay 'BILL000020', 970000, '2025-07-19', '10:48:00'
EXEC Pay 'BILL000021', 1471000, '2025-07-07', '14:41:00'
EXEC Pay 'BILL000022', 955000, '2025-07-12', '11:20:00'
EXEC Pay 'BILL000023', 854000, '2025-07-23', '17:01:00'
EXEC Pay 'BILL000024', 735000, '2025-07-06', '13:33:00'
EXEC Pay 'BILL000025', 971000, '2025-07-11', '15:27:00'
EXEC Pay 'BILL000026', 863000, '2025-07-15', '10:09:00'
EXEC Pay 'BILL000027', 831000, '2025-07-16', '09:50:00'
EXEC Pay 'BILL000028', 834000, '2025-07-20', '14:05:00'
EXEC Pay 'BILL000029', 1638000, '2025-07-30', '11:11:00'
EXEC Pay 'BILL000030', 876000, '2025-07-29', '08:18:00'
EXEC Pay 'BILL000031', 570000, '2025-07-25', '12:42:00'
GO
