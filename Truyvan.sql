--Câu 1: Liệt kê tên khách hàng, số điện thoại và tổng tiền họ đã chi trả, chỉ bao gồm khách có tên chứa chữ 'Lan'
SELECT 
    c.Customer_Name,
    c.Customer_Phone,
    SUM(b.Final_Price) AS Total_Spent
FROM Customer c
JOIN Bill b ON c.Customer_Phone = b.Customer_Phone
WHERE c.Customer_Name LIKE N'%Lan%'
GROUP BY c.Customer_Name, c.Customer_Phone
HAVING SUM(b.Final_Price) > (
    SELECT AVG(Final_Price)
    FROM Bill
    WHERE Final_Price IS NOT NULL
)

--Câu 2: Tìm top 5 nhân viên có doanh số bán cao nhất (tổng tiền trong hóa đơn), kèm số hóa đơn đã lập
SELECT TOP 5 
    e.Employee_Name,
    COUNT(b.Bill_ID) AS Total_Bills,
    SUM(b.Final_Price) AS Total_Revenue
FROM Employee e
JOIN Bill b ON e.Employee_ID = b.Employee_ID
WHERE b.Final_Price > (
    SELECT AVG(Final_Price)
    FROM Bill
    WHERE Final_Price IS NOT NULL
)
GROUP BY e.Employee_Name
ORDER BY Total_Revenue DESC


--Câu 3: Thống kê số lượng sản phẩm được bán theo từng loại sản phẩm có tên chứa "socola", kèm tổng doanh thu
SELECT 
    p.Product_Name,
    COUNT(bd.Bill_ID) AS Number_Of_Sales,
    SUM(bd.Product_Amount * bd.Price) AS Total_Revenue
FROM Product p
JOIN Bill_Data bd ON p.Product_ID = bd.Product_ID
JOIN Bill b ON bd.Bill_ID = b.Bill_ID
WHERE p.Product_Name LIKE N'%socola%'
GROUP BY p.Product_Name
