--VIEW: Thông tin hóa đơn và khách hàng
CREATE VIEW View_Customer_Bills AS
SELECT 
    b.Bill_ID,
    b.Create_Date,
    b.Final_Price,
    b.Used_Point,
    c.Customer_Name,
    c.Point AS Current_Point
FROM Bill b
JOIN Customer c ON b.Customer_Phone = c.Customer_Phone;

--test
SELECT * FROM View_Customer_Bills;


--VIEW: Hóa đơn đã thanh toán
CREATE VIEW View_Paid_Bills AS
SELECT 
    Bill_ID,
    Create_Date,
    Payment_Date,
    Final_Price,
    Given_Money,
    Excess_Money
FROM Bill
WHERE Payment_Date IS NOT NULL;

--test
SELECT * FROM View_Paid_Bills;
