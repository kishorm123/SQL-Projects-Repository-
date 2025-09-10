-- Complete Hospital Management SQL (schema + sample data + procedures/functions + triggers + reports)
CREATE DATABASE IF NOT EXISTS hospitaldb;
USE hospitaldb;

-- ===== SCHEMA =====
-- Hospital Management Database Schema
CREATE DATABASE IF NOT EXISTS hospitaldb;
USE hospitaldb;

-- Patients Table
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    contact VARCHAR(50),
    admission_date DATE,
    discharge_date DATE,
    status VARCHAR(50) DEFAULT 'Admitted'
);

-- Doctors Table
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    contact VARCHAR(50)
);

-- Visits Table
CREATE TABLE Visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis VARCHAR(255),
    treatment VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Bills Table
CREATE TABLE Bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    visit_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'Unpaid',
    payment_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (visit_id) REFERENCES Visits(visit_id)
);


-- ===== SAMPLE DATA =====
INSERT INTO Patients (name, age, gender, contact, admission_date) VALUES
('Alice Smith', 30, 'Female', '1234567890', '2025-08-01'),
('Bob Johnson', 45, 'Male', '9876543210', '2025-08-02'),
('Charlie Brown', 28, 'Male', '5554443330', '2025-08-03');

INSERT INTO Doctors (name, specialization, contact) VALUES
('Dr. George', 'Cardiologist', '111222333'),
('Dr. Emily', 'Neurologist', '444555666');

INSERT INTO Visits (patient_id, doctor_id, visit_date, diagnosis, treatment) VALUES
(1, 1, '2025-08-05', 'Chest Pain', 'ECG + Medication'),
(2, 2, '2025-08-06', 'Migraine', 'MRI + Painkillers'),
(1, 2, '2025-08-10', 'Follow-up', 'Medication Adjustment');

INSERT INTO Bills (patient_id, visit_id, amount, payment_status) VALUES
(1, 1, 5000.00, 'Unpaid'),
(2, 2, 3000.00, 'Paid'),
(1, 3, 1500.00, 'Unpaid');

-- ===== PROCEDURES & FUNCTIONS =====
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


-- ===== TRIGGERS =====
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


-- ===== REPORTS =====
-- Reporting queries (use hospitaldb)
USE hospitaldb;

-- Patient visit history
SELECT p.name AS patient_name, v.visit_date, v.diagnosis, v.treatment
FROM Patients p
JOIN Visits v ON p.patient_id = v.patient_id;

-- Doctor’s appointments
SELECT d.name AS doctor, v.visit_date, p.name AS patient, v.diagnosis
FROM Doctors d
JOIN Visits v ON d.doctor_id = v.doctor_id
JOIN Patients p ON v.patient_id = p.patient_id;

-- Billing summary per patient
SELECT p.name AS patient_name, SUM(b.amount) AS total_billed,
       SUM(CASE WHEN b.payment_status = 'Paid' THEN b.amount ELSE 0 END) AS total_paid,
       SUM(CASE WHEN b.payment_status = 'Unpaid' THEN b.amount ELSE 0 END) AS total_due
FROM Patients p
JOIN Bills b ON p.patient_id = b.patient_id
GROUP BY p.name;

