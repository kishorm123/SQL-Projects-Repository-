-- Stored Procedures and Functions (use patient name)
USE hospitaldb;
DELIMITER $$

CREATE PROCEDURE GetTotalBillByName(IN p_patient_name VARCHAR(100))
BEGIN
    DECLARE v_patient_id INT;
    DECLARE total DECIMAL(10,2);

    -- Find patient ID from name
    SELECT patient_id INTO v_patient_id
    FROM Patients
    WHERE name = p_patient_name
    LIMIT 1;

    -- Calculate total bill
    SELECT SUM(amount) INTO total
    FROM Bills
    WHERE patient_id = v_patient_id;

    SELECT CONCAT('Total bill for ', p_patient_name, ' = ', IFNULL(total, 0)) AS message;
END$$

CREATE FUNCTION GetOutstandingBalanceByName(p_patient_name VARCHAR(100))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_patient_id INT;
    DECLARE balance DECIMAL(10,2);

    -- Find patient ID from name
    SELECT patient_id INTO v_patient_id
    FROM Patients
    WHERE name = p_patient_name
    LIMIT 1;

    -- Calculate outstanding balance
    SELECT SUM(amount) INTO balance
    FROM Bills
    WHERE patient_id = v_patient_id AND payment_status = 'Unpaid';

    RETURN IFNULL(balance, 0);
END$$

DELIMITER ;
