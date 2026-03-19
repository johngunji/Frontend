INSERT INTO Patient VALUES
(1, 'Rahul Sharma', 45),
(2, 'John Doe', 50),
(3, 'Amit Patel', 42),
(4, 'Riya Singh', 30);

INSERT INTO Visit VALUES
(101, 1, '2026-03-10', 'Diabetes'),
(102, 1, '2026-03-15', 'Hypertension'),
(103, 2, '2026-03-12', 'Fever'),
(104, 3, '2026-03-14', 'Asthma');

INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM Patient'),
('SELECT * FROM Patient WHERE age > 40'),
('SELECT * FROM Patient WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id'),
('SELECT COUNT(*) AS total_visits FROM Visit WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC LIMIT 1');

INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('show all patients', 'all patients', 'Retrieval', 1),
('patients above 40', 'above 40', 'Retrieval', 2),
('show patient', 'show patient', 'Retrieval', 3),
('show visits', 'show visits', 'Retrieval', 4),
('count visits', 'count visits', 'Calculation', 5),
('latest visit', 'latest visit', 'Retrieval', 6);
