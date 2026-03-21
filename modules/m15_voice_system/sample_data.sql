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

INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM Patient WHERE 1=1 :conditions'),
('SELECT * FROM Patient WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC'),
('SELECT COUNT(*) AS total_visits FROM Visit WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC LIMIT 1'),
('SELECT p.name, v.visit_date, v.diagnosis FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE 1=1 :conditions ORDER BY v.visit_date DESC'),
('SELECT b.amount, b.payment_status, v.visit_date, p.name AS patient_name FROM Billing b JOIN Visit v ON b.visit_id = v.visit_id JOIN Patient p ON v.patient_id = p.patient_id WHERE 1=1 :conditions ORDER BY v.visit_date DESC'),
('SELECT DISTINCT p.patient_id, p.name, p.age, p.gender, v.diagnosis FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE LOWER(v.diagnosis) LIKE LOWER(CONCAT(''%'','':diagnosis'',''%'')) AND 1=1 :conditions'),
('SELECT pr.medicine_name, pr.dosage, pr.duration, v.visit_date, v.diagnosis FROM Prescription pr JOIN Visit v ON pr.visit_id = v.visit_id WHERE v.patient_id = :patient_id ORDER BY v.visit_date DESC'),
('SELECT * FROM Doctor ORDER BY specialization'),
('SELECT p.name AS patient_name, v.visit_date, v.diagnosis, d.name AS doctor_name FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE v.doctor_id = :patient_id ORDER BY v.visit_date DESC'),
('SELECT p.name, v.visit_date, v.diagnosis, d.name AS doctor FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE DATE(v.visit_date) = CURDATE()'),
('SELECT p.name, v.visit_date, v.diagnosis FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id WHERE MONTH(v.visit_date) = MONTH(CURDATE()) AND YEAR(v.visit_date) = YEAR(CURDATE()) ORDER BY v.visit_date DESC'),
('SELECT COUNT(*) AS total_patients FROM Patient WHERE 1=1 :conditions'),
('SELECT p.name, b.amount, b.payment_status, v.visit_date FROM Billing b JOIN Visit v ON b.visit_id = v.visit_id JOIN Patient p ON v.patient_id = p.patient_id WHERE b.payment_status = ''Pending'' ORDER BY v.visit_date DESC');

INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('all patients',         'patients,all,age,female,above,below',       'Retrieval',   1),
('patient by id',        'patient,id,find,number',                    'Retrieval',   2),
('visits of patient',    'visits,visit,list,show',                    'Retrieval',   3),
('count visits',         'count,visits,total,how',                    'Calculation', 4),
('latest visit',         'latest,recent,last,visit',                  'Retrieval',   5),
('patient history',      'history,previous,past,old',                 'Retrieval',   6),
('billing',              'billing,bill,payment,paid',                 'Retrieval',   7),
('diagnosis patients',   'diabetic,diagnosis,disease,patients',       'Retrieval',   8),
('diagnosis filter',     'hypertension,thyroid,fever,asthma',         'Retrieval',   8),
('prescriptions',        'prescription,prescriptions,medicine,drugs', 'Retrieval',   9),
('doctors',              'doctors,doctor,specialist,specialists',     'Retrieval',   10),
('doctor visits',        'doctor,conducted,seen,treated',             'Retrieval',   11),
('today visits',         'today,visits,todays,current',               'Retrieval',   12),
('this month visits',    'month,monthly,this,week',                   'Retrieval',   13),
('count patients',       'count,patients,total,many',                 'Calculation', 14),
('pending bills',        'pending,unpaid,bills,dues',                 'Retrieval',   15);

-- M14 Integration: Sample Lab Data
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

-- M14 Integration: New SQL Actions
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT t.test_name, r.result_value, t.unit, r.result_date, CASE WHEN r.result_value > t.normal_max THEN ''HIGH'' WHEN r.result_value < t.normal_min THEN ''LOW'' ELSE ''NORMAL'' END as status FROM LabResult r JOIN LabTest t ON r.test_id = t.test_id WHERE r.patient_id = :patient_id ORDER BY r.result_date DESC', 'M14'),
('SELECT t.test_name, r.result_date, r.result_value, (r.result_value - LAG(r.result_value) OVER (PARTITION BY t.test_id ORDER BY r.result_date)) as change_from_last_visit FROM LabResult r JOIN LabTest t ON r.test_id = t.test_id WHERE r.patient_id = :patient_id ORDER BY t.test_name, r.result_date DESC', 'M14');

-- M14 Integration: New Command Templates
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('patient lab results', 'lab,labs,test,results', 'Retrieval', 16),
('patient lab trends', 'trend,trends,change,tracking', 'Retrieval', 17);
