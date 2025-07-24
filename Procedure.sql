--Cập nhật điểm của khách hàng sau khi họ:
--Dùng điểm để giảm giá
--Nhận điểm thưởng sau thanh toán
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

-- test
EXEC Update_Point_For_Customer '0934567890', 10, 5 -- out: 30
SELECT * FROM Customer WHERE Customer_Phone = '0934567890';




--Tổng tiền sản phẩm (Primary_Price)
--Sử dụng điểm (tối đa 50 điểm hoặc theo giá trị)
--Áp dụng voucher nếu đủ điều kiện
--Tính giá cuối cùng phải trả (Final_Price)
--Tính điểm tích lũy (Earned_Point)
--Gọi lại procedure Update_Point_For_Customer
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

--test

EXEC Calculate_Bill 'BILL000002';
SELECT * FROM Bill WHERE Bill_ID = 'BILL000002';
SELECT * FROM Customer WHERE Customer_Phone = '0934567890';



--Nhận số tiền khách đưa
--Kiểm tra đủ tiền không
--Tính tiền thừa
--Ghi nhận ngày/giờ thanh toán
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

--test
EXEC Pay 'BILL000002', 600000;
SELECT Payment_Date, Payment_Time, Given_Money, Excess_Money
FROM Bill WHERE Bill_ID = 'BILL000002';
-- Ngày giờ được gán hiện tại
-- Tiền thừa = Given_Money - Final_Price

EXEC Pay 'BILL000002', 100000;
--Output: Error! Given_Money must be greater or equal to Final_Price!
