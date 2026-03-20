-- Patients
INSERT INTO Patient (name, age, gender, phone) VALUES
('Rahul Sharma', 45, 'Male', '9999999991'),
('John Doe', 50, 'Male', '9999999992'),
('Amit Patel', 42, 'Male', '9999999993'),
('Riya Singh', 30, 'Female', '9999999994'),
('Sunita Verma', 55, 'Female', '9999999995'),
('Karan Mehta', 38, 'Male', '9999999996');

-- Doctors
INSERT INTO Doctor (name, specialization) VALUES
('Dr. Mehta', 'Cardiology'),
('Dr. Rao', 'General Medicine'),
('Dr. Sharma', 'Endocrinology');

-- Visits
INSERT INTO Visit (patient_id, doctor_id, visit_date, diagnosis) VALUES
(1, 1, '2026-03-10', 'Diabetes'),
(1, 2, '2026-03-15', 'Hypertension'),
(2, 2, '2026-03-12', 'Fever'),
(3, 1, '2026-03-14', 'Asthma'),
(4, 3, '2026-03-16', 'Thyroid'),
(5, 1, '2026-03-17', 'Cardiac');

-- Prescriptions
INSERT INTO Prescription (visit_id, medicine_name, dosage, duration) VALUES
(1, 'Metformin', '500mg', '30 days'),
(2, 'Amlodipine', '5mg', '15 days'),
(3, 'Paracetamol', '650mg', '5 days'),
(4, 'Salbutamol', '2mg', '10 days'),
(5, 'Levothyroxine', '50mcg', '60 days');

-- Billing
INSERT INTO Billing (visit_id, amount, payment_status) VALUES
(1, 500.00, 'Paid'),
(2, 700.00, 'Pending'),
(3, 300.00, 'Paid'),
(4, 450.00, 'Pending'),
(5, 600.00, 'Paid');

-- SQL Actions
INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM Patient WHERE 1=1 :conditions'),
('SELECT * FROM Patient WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id'),
('SELECT COUNT(*) AS total_visits FROM Visit WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC LIMIT 1'),
('SELECT p.name, v.visit_date, v.diagnosis FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE 1=1 :conditions'),
('SELECT b.amount, b.payment_status, v.visit_date FROM Billing b JOIN Visit v ON b.visit_id = v.visit_id WHERE 1=1 :conditions');

-- Command Templates
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('show all patients',           'all,patients,show',        'Retrieval',    1),
('show patient by id',          'patient,id,show',          'Retrieval',    2),
('show visits of patient',      'visit,visits,patient',     'Retrieval',    3),
('count visits of patient',     'count,visits,patient',     'Calculation',  4),
('latest visit of patient',     'latest,visit,patient',     'Retrieval',    5),
('show patient visit history',  'history,visit,patient',    'Retrieval',    6),
('show billing',                'billing,payment,bill',     'Retrieval',    7);
