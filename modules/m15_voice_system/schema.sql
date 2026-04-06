CREATE TABLE IF NOT EXISTS Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Doctor (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS Visit (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
);

CREATE TABLE IF NOT EXISTS Prescription (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(50),
    duration VARCHAR(50),
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id)
);

CREATE TABLE IF NOT EXISTS Billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id)
);

CREATE TABLE IF NOT EXISTS SQL_Action (
    sql_action_id INT PRIMARY KEY AUTO_INCREMENT,
    sql_query TEXT NOT NULL,
    target_module VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS CommandTemplate (
    template_id INT PRIMARY KEY AUTO_INCREMENT,
    template_pattern VARCHAR(255) NOT NULL,
    keyword VARCHAR(100) NOT NULL,
    command_type ENUM('Retrieval','Calculation','Update','Summary') NOT NULL,
    sql_action_id INT NOT NULL,
    FOREIGN KEY (sql_action_id) REFERENCES SQL_Action(sql_action_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS VoiceCommand (
    command_id INT PRIMARY KEY AUTO_INCREMENT,
    command_text TEXT NOT NULL,
    template_id INT,
    execution_status ENUM('PENDING','DONE','FAILED') DEFAULT 'PENDING',
    response_text TEXT,
    issued_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES CommandTemplate(template_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Context (
    context_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT NOT NULL,
    context_type VARCHAR(50) NOT NULL,
    context_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (command_id) REFERENCES VoiceCommand(command_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ExecutionLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT,
    executed_query TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (command_id) REFERENCES VoiceCommand(command_id) ON DELETE CASCADE
);

-- M14 Integration: Laboratory Tables
CREATE TABLE IF NOT EXISTS LabTest (
    test_id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    normal_min DECIMAL(10,2),
    normal_max DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS LabResult (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    visit_id INT,
    test_id INT,
    result_value DECIMAL(10,2) NOT NULL,
    result_date DATE NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id),
    FOREIGN KEY (test_id) REFERENCES LabTest(test_id)
);


-- M15 NLP: Summary Template Table
CREATE TABLE IF NOT EXISTS SummaryTemplate (
    summary_id INT PRIMARY KEY AUTO_INCREMENT,
    summary_type VARCHAR(50) NOT NULL,
    summary_sql TEXT NOT NULL,
    description VARCHAR(255)
);
