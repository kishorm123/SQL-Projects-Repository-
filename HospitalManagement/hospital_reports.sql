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
