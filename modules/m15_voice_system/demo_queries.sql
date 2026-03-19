-- Insert SQL actions
INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM patients WHERE patient_id = :patient_id'),
('SELECT * FROM patients WHERE age > :value'),
('SELECT * FROM patients');

-- Insert templates
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('show patient', 'patient', 'Retrieval', 1),
('patient above', 'above', 'Retrieval', 2),
('all patients', 'all', 'Retrieval', 3);
