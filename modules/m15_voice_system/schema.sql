CREATE TABLE Patient (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    age INT
);

CREATE TABLE Visit (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    visit_date DATE,
    diagnosis VARCHAR(100),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);

CREATE TABLE SQL_Action (
    sql_action_id INT PRIMARY KEY AUTO_INCREMENT,
    sql_query TEXT NOT NULL,
    target_module VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE SummaryTemplate (
    summary_id INT PRIMARY KEY AUTO_INCREMENT,
    summary_type VARCHAR(50),
    format_description TEXT
);

CREATE TABLE CommandTemplate (
    template_id INT PRIMARY KEY AUTO_INCREMENT,
    template_pattern VARCHAR(255) NOT NULL,
    keyword VARCHAR(100) NOT NULL UNIQUE,
    command_type ENUM('Retrieval','Calculation','Update','Summary') NOT NULL,
    sql_action_id INT NOT NULL,
    summary_id INT NULL,
    FOREIGN KEY (sql_action_id) REFERENCES SQL_Action(sql_action_id) ON DELETE CASCADE,
    FOREIGN KEY (summary_id) REFERENCES SummaryTemplate(summary_id) ON DELETE SET NULL
);

CREATE INDEX idx_keyword ON CommandTemplate(keyword);

CREATE TABLE VoiceCommand (
    command_id INT PRIMARY KEY AUTO_INCREMENT,
    command_text TEXT NOT NULL,
    template_id INT,
    execution_status ENUM('PENDING','DONE','FAILED') DEFAULT 'PENDING',
    response_text TEXT,
    issued_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES CommandTemplate(template_id) ON DELETE SET NULL
);

CREATE TABLE Context (
    context_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT NOT NULL,
    context_type VARCHAR(50) NOT NULL,
    context_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (command_id) REFERENCES VoiceCommand(command_id) ON DELETE CASCADE
);

CREATE INDEX idx_context ON Context(command_id, context_type);

CREATE TABLE ExecutionLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    command_id INT,
    executed_query TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (command_id) REFERENCES VoiceCommand(command_id) ON DELETE CASCADE
);
