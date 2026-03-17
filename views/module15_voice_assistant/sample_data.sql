
-- Supporting tables (REQUIRED)

CREATE TABLE Patient (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT
);

CREATE TABLE Visit (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    visit_date DATE,
    diagnosis VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

-- Patient data

INSERT INTO Patient VALUES
(1, 'Rahul Sharma', 45),
(2, 'John Doe', 50),
(3, 'Amit Patel', 42),
(4, 'Riya Singh', 30);

-- Visit data

INSERT INTO Visit VALUES
(101, 1, '2026-03-10', 'Diabetes'),
(102, 1, '2026-03-15', 'Hypertension'),
(103, 2, '2026-03-12', 'Fever'),
(104, 3, '2026-03-14', 'Asthma');

-- SQL actions

INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM Patient'),
('SELECT * FROM Patient WHERE age > 40'),
('SELECT * FROM Visit WHERE patient_id = :patient_id'),
('SELECT COUNT(*) FROM Visit WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id ORDER BY visit_date DESC LIMIT 1');

-- Command templates

INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('show all patients', 'all patients', 'Retrieval', 1),
('patients above 40', 'above 40', 'Retrieval', 2),
('show visits', 'visits', 'Retrieval', 3),
('count visits', 'count visits', 'Calculation', 4),
('latest visit', 'latest visit', 'Retrieval', 5);