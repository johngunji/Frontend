CREATE OR REPLACE VIEW PatientVisitSummary AS
SELECT p.patient_id, p.name, p.age,
       COUNT(v.visit_id) AS total_visits
FROM Patient p
LEFT JOIN Visit v ON p.patient_id = v.patient_id
GROUP BY p.patient_id;

CREATE OR REPLACE VIEW PatientsAbove40 AS
SELECT patient_id, name, age, gender
FROM Patient WHERE age > 40;

CREATE OR REPLACE VIEW CommandHistory AS
SELECT command_id, command_text,
       execution_status, response_text, issued_time
FROM VoiceCommand;

CREATE OR REPLACE VIEW ExecutionDetails AS
SELECT e.log_id, v.command_text,
       v.execution_status, e.executed_query, e.executed_at
FROM ExecutionLog e
JOIN VoiceCommand v ON e.command_id = v.command_id;

CREATE OR REPLACE VIEW DiagnosisFrequency AS
SELECT diagnosis, COUNT(*) AS total_cases
FROM Visit
GROUP BY diagnosis
ORDER BY total_cases DESC;
