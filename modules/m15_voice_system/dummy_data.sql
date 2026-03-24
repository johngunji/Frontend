-- Mock Operational Data (Testing Only)
INSERT INTO Patient (name, age, gender, phone) VALUES
('Rahul Sharma',   45, 'Male',   '9999999991'),
('John Doe',       50, 'Male',   '9999999992'),
('Amit Patel',     42, 'Male',   '9999999993'),
('Riya Singh',     30, 'Female', '9999999994'),
('Sunita Verma',   55, 'Female', '9999999995'),
('Karan Mehta',    38, 'Male',   '9999999996'),
('Priya Nair',     28, 'Female', '9999999997'),
('Suresh Babu',    62, 'Male',   '9999999998'),
('Anita Joshi',    47, 'Female', '9999999999'),
('Rajan Kumar',    35, 'Male',   '9999999900');

INSERT INTO Doctor (name, specialization) VALUES
('Dr. Mehta',   'Cardiology'),
('Dr. Rao',     'General Medicine'),
('Dr. Sharma',  'Endocrinology'),
('Dr. Nair',    'Pulmonology'),
('Dr. Verma',   'Neurology');

INSERT INTO Visit (patient_id, doctor_id, visit_date, diagnosis) VALUES
(1,  1, '2026-03-10', 'Diabetes'),
(1,  2, '2026-03-15', 'Hypertension'),
(2,  2, '2026-03-12', 'Fever'),
(3,  1, '2026-03-14', 'Asthma'),
(4,  3, '2026-03-16', 'Thyroid'),
(5,  1, '2026-03-17', 'Cardiac'),
(6,  4, '2026-03-18', 'Diabetes'),
(7,  2, '2026-03-19', 'Fever'),
(8,  5, '2026-03-19', 'Migraine'),
(9,  3, '2026-03-20', 'Hypertension'),
(10, 1, '2026-03-20', 'Asthma'),
(4,  3, '2026-03-21', 'Diabetes'),
(5,  3, '2026-03-21', 'Diabetes'),
(7,  3, '2026-03-21', 'Diabetes');

INSERT INTO Prescription (visit_id, medicine_name, dosage, duration) VALUES
(1,  'Metformin',     '500mg',  '30 days'),
(2,  'Amlodipine',    '5mg',    '15 days'),
(3,  'Paracetamol',   '650mg',  '5 days'),
(4,  'Salbutamol',    '2mg',    '10 days'),
(5,  'Levothyroxine', '50mcg',  '60 days'),
(6,  'Metformin',     '1000mg', '30 days'),
(7,  'Cetirizine',    '10mg',   '7 days'),
(8,  'Sumatriptan',   '50mg',   '5 days'),
(9,  'Amlodipine',    '10mg',   '30 days'),
(10, 'Montelukast',   '10mg',   '15 days');

INSERT INTO Billing (visit_id, amount, payment_status) VALUES
(1,  500.00, 'Paid'),
(2,  700.00, 'Pending'),
(3,  300.00, 'Paid'),
(4,  450.00, 'Pending'),
(5,  600.00, 'Paid'),
(6,  550.00, 'Pending'),
(7,  250.00, 'Paid'),
(8,  800.00, 'Pending'),
(9,  650.00, 'Paid'),
(10, 400.00, 'Pending');

INSERT INTO LabTest (test_name, unit, normal_min, normal_max) VALUES
('Fasting Blood Glucose', 'mg/dL', 70.00, 99.00),
('Hemoglobin A1c', '%', 4.00, 5.60),
('Serum Creatinine', 'mg/dL', 0.74, 1.35);

INSERT INTO LabResult (patient_id, visit_id, test_id, result_value, result_date) VALUES
(1, 1, 1, 125.00, '2025-01-15'),
(1, 1, 2, 7.20, '2025-01-15'),
(1, 2, 1, 118.00, '2025-02-15'),
(1, 2, 2, 6.80, '2025-02-15'),
(1, 2, 1, 105.00, '2026-03-10');
