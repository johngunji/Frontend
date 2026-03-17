CREATE VIEW PatientVisitSummary AS
SELECT 
    p.patient_id,
    p.name,
    p.age,
    COUNT(v.visit_id) AS total_visits
FROM Patient p
LEFT JOIN Visit v ON p.patient_id = v.patient_id
GROUP BY p.patient_id;

CREATE VIEW PatientsAbove40 AS
SELECT 
    patient_id,
    name,
    age
FROM Patient
WHERE age > 40;

CREATE VIEW CommandHistory AS
SELECT 
    command_id,
    command_text,
    execution_status,
    issued_time
FROM VoiceCommand;

CREATE VIEW ExecutionDetails AS
SELECT 
    e.log_id,
    v.command_text,
    e.executed_query,
    e.executed_at
FROM ExecutionLog e
JOIN VoiceCommand v ON e.command_id = v.command_id;