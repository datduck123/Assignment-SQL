--Tạo hàm tính tổng doanh thu của 1 khách
CREATE FUNCTION Get_Total_Revenue(@Phone VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @Total INT
    SELECT @Total = SUM(Final_Price)
    FROM Bill
    WHERE Customer_Phone = @Phone
    RETURN ISNULL(@Total, 0)
END

--test
SELECT dbo.Get_Total_Revenue('0934567890') AS TotalSpent;
