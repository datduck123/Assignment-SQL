UPDATE Employee
SET Employee_Address = N'TP. Hồ Chí Minh' -- An Nhơn --> TP. Hồ Chí Minh
WHERE Employee_ID = 'EMPQN001';

UPDATE Customer
SET Point = Point + 10
WHERE Customer_Phone = '0934567890';

SELECT * FROM Customer WHERE Customer_Phone = '0934567890'; --kiểm tra


DELETE FROM Customer
WHERE Point < 5;


DELETE FROM Bill
WHERE Final_Price < 350000;



ALTER TABLE Customer
ADD Email NVARCHAR(100);
