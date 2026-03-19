CREATE TABLE SQL_Action (
    sql_action_id INT PRIMARY KEY AUTO_INCREMENT,
    sql_query TEXT NOT NULL,
    target_module VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CommandTemplate (
    template_id INT PRIMARY KEY AUTO_INCREMENT,
    template_pattern VARCHAR(255) NOT NULL,
    keyword VARCHAR(100) NOT NULL,
    command_type ENUM('Retrieval','Calculation','Update','Summary') NOT NULL,
    sql_action_id INT NOT NULL,
    FOREIGN KEY (sql_action_id) REFERENCES SQL_Action(sql_action_id) ON DELETE CASCADE
);

CREATE INDEX idx_keyword ON CommandTemplate(keyword);

CREATE TABLE ExecutionLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    executed_query TEXT,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
