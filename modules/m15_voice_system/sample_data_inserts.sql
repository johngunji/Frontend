-- Insert SQL actions
INSERT INTO SQL_Action (sql_query) VALUES
('SELECT * FROM Patient WHERE 1=1 :conditions'),
('SELECT * FROM Patient WHERE patient_id = :patient_id'),
('SELECT * FROM Visit WHERE patient_id = :patient_id');

-- Insert templates with comma-separated keywords
INSERT INTO CommandTemplate (template_pattern, keyword, command_type, sql_action_id) VALUES
('show all patients',      'all,patients,show',   'Retrieval', 1),
('show patient by id',     'patient,id,show',     'Retrieval', 2),
('show visits of patient', 'visit,visits,patient','Retrieval', 3);
