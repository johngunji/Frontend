-- Patients
INSERT INTO Patient (name, age, gender, phone) VALUES
('Rahul Sharma', 45, 'Male', '9999999991'),
('John Doe', 50, 'Male', '9999999992'),
('Amit Patel', 42, 'Male', '9999999993'),
('Riya Singh', 30, 'Female', '9999999994');

-- Doctors
INSERT INTO Doctor (name, specialization) VALUES
('Dr. Mehta', 'Cardiology'),
('Dr. Rao', 'General Medicine');

-- Visits
INSERT INTO Visit (patient_id, doctor_id, visit_date, diagnosis) VALUES
(1, 1, '2026-03-10', 'Diabetes'),
(1, 2, '2026-03-15', 'Hypertension'),
(2, 2, '2026-03-12', 'Fever'),
(3, 1, '2026-03-14', 'Asthma');

-- Prescriptions
INSERT INTO Prescription (visit_id, medicine_name, dosage, duration) VALUES
(1, 'Metformin', '500mg', '30 days'),
(2, 'Amlodipine', '5mg', '15 days'),
(3, 'Paracetamol', '650mg', '5 days');

-- Billing
INSERT INTO Billing (visit_id, amount, payment_status) VALUES
(1, 500.00, 'Paid'),
(2, 700.00, 'Pending'),
(3, 300.00, 'Paid');
