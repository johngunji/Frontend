-- Core NLP Engine Configuration (System Data)
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT * FROM Patient WHERE 1=1 :conditions', 'M15'),
('SELECT * FROM Patient WHERE patient_id = :patient_id', 'M15'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC', 'M15'),
('SELECT COUNT(*) AS total_visits FROM Visit WHERE patient_id = :patient_id', 'M15'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC LIMIT 1', 'M15'),
('SELECT p.name, v.visit_date, v.diagnosis FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE 1=1 :conditions ORDER BY v.visit_date DESC', 'M15'),
('SELECT b.amount, b.payment_status, v.visit_date, p.name AS patient_name FROM Billing b JOIN Visit v ON b.visit_id = v.visit_id JOIN Patient p ON v.patient_id = p.patient_id WHERE 1=1 :conditions ORDER BY v.visit_date DESC', 'M15'),
('SELECT DISTINCT p.patient_id, p.name, p.age, p.gender, v.diagnosis FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE LOWER(v.diagnosis) LIKE LOWER(CONCAT(''%'','':diagnosis'',''%'')) AND 1=1 :conditions', 'M15'),
('SELECT pr.medicine_name, pr.dosage, pr.duration, v.visit_date, v.diagnosis FROM Prescription pr JOIN Visit v ON pr.visit_id = v.visit_id WHERE v.patient_id = :patient_id ORDER BY v.visit_date DESC', 'M15'),
('SELECT * FROM Doctor ORDER BY specialization', 'M15'),
('SELECT p.name AS patient_name, v.visit_date, v.diagnosis, d.name AS doctor_name FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE v.doctor_id = :patient_id ORDER BY v.visit_date DESC', 'M15'),
('SELECT p.name, v.visit_date, v.diagnosis, d.name AS doctor FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE DATE(v.visit_date) = CURDATE()', 'M15'),
('SELECT p.name, v.visit_date, v.diagnosis FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id WHERE MONTH(v.visit_date) = MONTH(CURDATE()) AND YEAR(v.visit_date) = YEAR(CURDATE()) ORDER BY v.visit_date DESC', 'M15'),
('SELECT COUNT(*) AS total_patients FROM Patient WHERE 1=1 :conditions', 'M15'),
('SELECT p.name, b.amount, b.payment_status, v.visit_date FROM Billing b JOIN Visit v ON b.visit_id = v.visit_id JOIN Patient p ON v.patient_id = p.patient_id WHERE b.payment_status = ''Pending'' :conditions ORDER BY v.visit_date DESC', 'M15'),
('SELECT t.test_name, r.result_value, t.unit, r.result_date, CASE WHEN r.result_value > t.normal_max THEN ''HIGH'' WHEN r.result_value < t.normal_min THEN ''LOW'' ELSE ''NORMAL'' END as status FROM LabResult r JOIN LabTest t ON r.test_id = t.test_id WHERE r.patient_id = :patient_id ORDER BY r.result_date DESC', 'M14'),
('SELECT t.test_name, r.result_date, r.result_value, (r.result_value - LAG(r.result_value) OVER (PARTITION BY t.test_id ORDER BY r.result_date)) as change_from_last_visit FROM LabResult r JOIN LabTest t ON r.test_id = t.test_id WHERE r.patient_id = :patient_id ORDER BY t.test_name, r.result_date DESC', 'M14'),
('SELECT p.name, v.visit_date, v.diagnosis, d.name AS doctor FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE DATE(v.visit_date) = '':visit_date'' ORDER BY v.visit_date DESC', 'M15');

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
('pending bills',        'pending,unpaid,bills,dues',                 'Retrieval',   15),
('patient lab results',  'lab,labs,test,results',                     'Retrieval',   16),
('patient lab trends',   'trend,trends,change,tracking',              'Retrieval',   17),
('specific date visits', 'date,on,visits,day',                        'Retrieval',   18);


INSERT INTO SummaryTemplate (summary_type, summary_sql, description) VALUES
('patient_overview',
 'SELECT p.name, p.age, COUNT(v.visit_id) AS total_visits, MAX(v.visit_date) AS last_visit FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE p.patient_id = 1 GROUP BY p.patient_id',
 'Quick summary of a single patient'),
('daily_summary',
 'SELECT COUNT(*) AS today_visits, COUNT(DISTINCT patient_id) AS unique_patients FROM Visit WHERE DATE(visit_date) = CURDATE()',
 'Todays activity at a glance');


-- Update type: Mark bill as paid
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('UPDATE Billing SET payment_status = ''Paid'' WHERE visit_id = :patient_id', 'M15');

INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('mark bill paid', 'mark,settle,clear,paid', 'Update', 19);

-- New SQL Actions
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT v.diagnosis, COUNT(*) AS total_cases FROM Visit v GROUP BY v.diagnosis ORDER BY total_cases DESC', 'M15'),
('SELECT p.name, p.age, p.gender, v.diagnosis, v.visit_date FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id WHERE p.age > 60', 'M15'),
('SELECT pr.medicine_name, COUNT(*) AS times_prescribed FROM Prescription pr GROUP BY pr.medicine_name ORDER BY times_prescribed DESC', 'M15'),
('SELECT d.name AS doctor, COUNT(v.visit_id) AS total_visits FROM Doctor d JOIN Visit v ON d.doctor_id = v.doctor_id GROUP BY d.doctor_id ORDER BY total_visits DESC', 'M15'),
('SELECT p.name, SUM(b.amount) AS total_billed FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id JOIN Billing b ON v.visit_id = b.visit_id GROUP BY p.patient_id ORDER BY total_billed DESC', 'M15');


-- New Command Templates
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('diagnosis frequency',  'diagnosis,frequency,common,most',           'Summary',     20),
('elderly patients',     'elderly,old,senior,above,60',               'Retrieval',   21),
('medicine frequency',   'medicine,prescribed,common,frequency',      'Summary',     22),
('doctor workload',      'workload,busiest,doctor,conducted',         'Summary',     23),
('patient billing total','total,billed,billing,highest,spent',        'Summary',     24);
-- Patient Summary (all-in-one)
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT p.name, p.age, p.gender, p.phone, v.visit_date, v.diagnosis, d.name AS doctor, pr.medicine_name, pr.dosage, b.amount, b.payment_status FROM Patient p LEFT JOIN Visit v ON p.patient_id = v.patient_id LEFT JOIN Doctor d ON v.doctor_id = d.doctor_id LEFT JOIN Prescription pr ON v.visit_id = pr.visit_id LEFT JOIN Billing b ON v.visit_id = b.visit_id WHERE p.patient_id = :patient_id ORDER BY v.visit_date DESC', 'M15');

-- Search by medicine
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT DISTINCT p.name, p.age, p.gender, pr.medicine_name, pr.dosage FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id JOIN Prescription pr ON v.visit_id = pr.visit_id WHERE LOWER(pr.medicine_name) LIKE LOWER(CONCAT(''%'','':diagnosis'',''%''))', 'M15');
-- High risk patients
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT DISTINCT p.name, p.age, v.diagnosis, b.payment_status, b.amount FROM Patient p JOIN Visit v ON p.patient_id = v.patient_id JOIN Billing b ON v.visit_id = b.visit_id WHERE b.payment_status = ''Pending'' ORDER BY b.amount DESC', 'M15');

-- Date range visits
INSERT INTO SQL_Action (sql_query, target_module) VALUES
('SELECT p.name, v.visit_date, v.diagnosis, d.name AS doctor FROM Visit v JOIN Patient p ON v.patient_id = p.patient_id JOIN Doctor d ON v.doctor_id = d.doctor_id WHERE v.visit_date BETWEEN :start_date AND :end_date ORDER BY v.visit_date DESC', 'M15');
-- New Command Templates
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('patient summary',    'summary,complete,full,overview',        'Summary',   25),
('medicine search',   'on,taking,prescribed,metformin,medicine','Retrieval', 26),
('high risk patients','risk,high,danger,critical,unpaid',       'Retrieval', 27),
('date range visits', 'between,from,range,and',                 'Retrieval', 28);
