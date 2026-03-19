

CREATE TABLE Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(15)
);

CREATE TABLE Doctor (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE Visit (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    diagnosis VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
);

CREATE TABLE Prescription (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT,
    medicine_name VARCHAR(100),
    dosage VARCHAR(50),
    duration VARCHAR(50),
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id)
);

CREATE TABLE Billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    visit_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (visit_id) REFERENCES Visit(visit_id)
);

-- =========================
-- EXISTING SYSTEM TABLES
-- =========================

CREATE TABLE SQL_Action (
    sql_action_id INT PRIMARY KEY AUTO_INCREMENT,
    sql_query TEXT NOT NULL,
    target_module VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CommandTemplate (
    template_id INT PRIMARY KEY AUTO_INCREMENT,
    template_pattern VARCHAR(255) NOT NULL,
    keyword VARCHAR(100) NOT NULL UNIQUE,
    command_type ENUM('Retrieval','Calculation','Update','Summary') NOT NULL,
    sql_action_id INT NOT NULL,
    FOREIGN KEY (sql_action_id) REFERENCES SQL_Action(sql_action_id)
);

CREATE TABLE VoiceCommand (
    command_id INT PRIMARY KEY AUTO_INCREMENT,
    command_text TEXT NOT NULL,
    template_id INT,
    execution_status ENUM('PENDING','DONE','FAILED') DEFAULT 'PENDING',
    response_text TEXT,
    issued_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Context (
    context_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT,
    context_type VARCHAR(50),
    context_value VARCHAR(255)
);

CREATE TABLE ExecutionLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT,
    executed_query TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
