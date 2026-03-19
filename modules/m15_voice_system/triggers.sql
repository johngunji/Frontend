DELIMITER //

-- 1. BEFORE INSERT → normalize + default status
CREATE TRIGGER before_insert_voicecommand
BEFORE INSERT ON VoiceCommand
FOR EACH ROW
BEGIN
    SET NEW.command_text = LOWER(NEW.command_text);
    SET NEW.execution_status = 'PENDING';
END//

-- 2. AFTER INSERT → auto context injection
CREATE TRIGGER after_insert_voicecommand
AFTER INSERT ON VoiceCommand
FOR EACH ROW
BEGIN
    INSERT INTO Context (command_id, context_type, context_value)
    VALUES (NEW.command_id, 'patient_id', '1');
END//

-- 3. BEFORE UPDATE → validate execution_status
CREATE TRIGGER before_update_voicecommand
BEFORE UPDATE ON VoiceCommand
FOR EACH ROW
BEGIN
    IF NEW.execution_status NOT IN ('PENDING','DONE','FAILED') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid execution status';
    END IF;
END//

DELIMITER ;