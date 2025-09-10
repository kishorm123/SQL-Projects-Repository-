-- Triggers for hospitaldb
USE hospitaldb;
DELIMITER $$

-- Trigger: Update patient status on discharge_date
CREATE TRIGGER trg_discharge_update
AFTER UPDATE ON Patients
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NOT NULL THEN
        UPDATE Patients
        SET status = 'Discharged'
        WHERE patient_id = NEW.patient_id;
    END IF;
END$$

-- Trigger: Update payment status when payment_date is set
CREATE TRIGGER trg_payment_update
BEFORE UPDATE ON Bills
FOR EACH ROW
BEGIN
    IF NEW.payment_date IS NOT NULL THEN
        SET NEW.payment_status = 'Paid';
    END IF;
END$$

DELIMITER ;
