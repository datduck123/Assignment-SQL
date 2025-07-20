--------------------------------------------------------
--                                                    --
--                    Write query                     --
--                                                    --
--------------------------------------------------------


USE PASTRY_SHOP
GO


-- Câu 1:
-- - Find the employee who generates the most invoices.
-- - Phong

SELECT *
FROM Employee
WHERE Employee_ID = ANY (SELECT TOP 1 WITH TIES Employee_ID
						 FROM Bill
						 GROUP BY Employee_ID
						 ORDER BY COUNT(Bill_ID) DESC)


-- Câu 2:
-- - Display purchase history of member customers with phone number '0956789012'
-- - Information to display: Bill ID, Create_Date, Create_Time, Product Name, Product Amount
-- - Đạt
SELECT B.Bill_ID, B.Create_Date, B.Create_Time, P.Product_Name, BD.Product_Amount
FROM Bill B
	JOIN Customer C ON B.Customer_Phone = C.Customer_Phone
	JOIN Bill_Data BD ON B.Bill_ID = BD.Bill_ID
	JOIN Product P ON BD.Product_ID = P.Product_ID
WHERE C.Customer_Phone = '0956789012'
ORDER BY B.Bill_ID ASC, P.Product_ID ASC


-- Câu 3:
-- - Show the number of times the vouchers have been applied
-- - Information to display: Voucher ID, Total time applied
-- - Duy

SELECT      v.Voucher_ID AS [Voucher ID],
            COUNT(*) AS [Total times applied]

FROM        Voucher v LEFT JOIN Bill b ON v.Voucher_ID = b.Voucher_ID
GROUP BY    v.Voucher_ID
ORDER BY    [Total times applied] DESC


-- Câu 4:
-- - Show list of invoices of employee 'Nguyễn Thị Thúy'
-- - Information to display: Bill ID, Customer Phone, Employee ID
-- - Duy

SELECT Bill_ID, Customer_Phone, Employee_ID
FROM Bill
WHERE Employee_ID = (SELECT Employee_ID
					 FROM Employee
					 WHERE Employee_Name = N'Nguyễn Thị Thúy')


-- Câu 5:
-- - Show total sales of each month
-- - Information to display: Year, Month, Total revenue
-- - Khoa

SELECT      YEAR(b.Payment_Date) AS [Year],
            MONTH(b.Payment_Date) AS [Month],
            SUM(b.Final_Price) AS [Total revenue]
            
FROM        Bill b
GROUP BY    YEAR(b.Payment_Date),
            MONTH(b.Payment_Date)

-- Câu 6:
-- - Showing best seller products of July
-- - Information to display: Product Name, Total sold
-- - Khoa

/*	SELECT p.Product_Name, SUM(bd.Product_Amount) AS Total_sold
	FROM Bill_Data AS bd
		JOIN Product p ON bd.Product_ID = p.Product_ID
		JOIN Bill b ON bd.Bill_ID = b.Bill_ID
	WHERE MONTH(b.Payment_Date) = 7
	GROUP BY p.Product_Name
	*/

	SELECT TOP 1 WITH TIES p.Product_Name, SUM(bd.Product_Amount) AS [Total sold]
	FROM Bill_Data AS bd
		JOIN Product p ON bd.Product_ID = p.Product_ID
		JOIN Bill b ON bd.Bill_ID = b.Bill_ID
	WHERE MONTH(b.Payment_Date) = 7
	GROUP BY p.Product_Name
	ORDER BY [Total sold] DESC;

-- Câu 7:
-- - Display the member customer with the largest purchase invoice in June and that invoice information
-- - Information to display: Bill ID, Final Price
-- - Quân

/*	SELECT c.Customer_Name, b.Bill_ID, b.Final_Price
	FROM Customer c
		JOIN Bill b ON c.Customer_Phone = b.Customer_Phone
	WHERE MONTH(b.Payment_Date) = 6
	ORDER BY b.Final_Price DESC;
	*/

	SELECT TOP 1 WITH TIES c.Customer_Name, b.Bill_ID, b.Final_Price
	FROM Customer c
		JOIN Bill b ON c.Customer_Phone = b.Customer_Phone
	WHERE MONTH(b.Payment_Date) = 6
	ORDER BY b.Final_Price DESC;


-- Câu 8:
-- - Display product information with the most purchases of customers who do not register for membership
-- - Information to display: Product ID, Product Name, Total amount sold
-- - Quân

SELECT TOP 1 WITH TIES P.Product_ID, P.Product_Name, SUM(BD.Product_Amount) AS [Total amount sold]
FROM Product P
	JOIN Bill_Data BD ON P.Product_ID = BD.Product_ID
	JOIN Bill BL ON BD.Bill_ID = BL.Bill_ID
WHERE BL.Customer_Phone IS NULL
GROUP BY P.Product_ID, P.Product_Name
ORDER BY [Total amount sold] DESC

-- Câu 9: Write trigger:
-- Orders with total amount < 50,000 VND are not allowed.
-- Automatically add bonus points to customers (1 point for every 50,000 VND).
-- Phong

CREATE OR ALTER TRIGGER trg_ValidateAndRewardOrder
ON Orders
AFTER INSERT
AS
BEGIN
    DECLARE @OrderID INT, @CustomerID INT, @TotalAmount MONEY;

    SELECT TOP 1
        @OrderID = i.OrderID,
        @CustomerID = i.CustomerID,
        @TotalAmount = i.TotalAmount
    FROM inserted i;

    -- Check if total amount is valid
    IF @TotalAmount < 50000
    BEGIN
        -- Cancel the order (delete from Orders table)
        DELETE FROM Orders WHERE OrderID = @OrderID;

        -- Raise an error to inform the user
        RAISERROR(N'The total amount must be at least 50,000 VND.', 16, 1);
        RETURN;
    END

    -- Add bonus points (1 point per 50,000 VND)
    DECLARE @PointBonus INT = FLOOR(@TotalAmount / 50000);

    UPDATE Customer
    SET Point = Point + @PointBonus
    WHERE CustomerID = @CustomerID;
END;

-- TEST
-- (deleted, erorr)
INSERT INTO Orders (OrderID, CustomerID, TotalAmount) VALUES (201, 1, 30000);

-- (hold, bonus)
INSERT INTO Orders (OrderID, CustomerID, TotalAmount) VALUES (202, 1, 120000);

