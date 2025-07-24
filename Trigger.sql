-- STEP 12: Trigger for Employee table
-- Format: EMPQN001, EMPQN002, EMPQN003,...
-- Must have exactly 10 numbers starting with 0 and the second number not being zero 
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

--test
INSERT INTO Employee (Employee_ID, Employee_Name, Employee_Phone, Employee_Address)
VALUES ('EMPQN007', N'Nguyễn Văn B', '0912345678', N'Thủ Đức');

select * from Employee





-- STEP 14: Trigger for Voucher table
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


-- test
INSERT INTO Voucher (Voucher_ID, Voucher_Description, Discount, Required_Total_Revenue, Begin_Date, End_Date, Is_Require_Member)
VALUES ('VC006', N'Giảm 10% mùa tựu trường', 10, 100000, '2025-08-01', '2025-08-31', 1);

select * from voucher

