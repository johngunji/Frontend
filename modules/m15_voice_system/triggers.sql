DELIMITER //

-- 1: normalize input and set default status before insert
CREATE TRIGGER before_insert_voicecommand
BEFORE INSERT ON VoiceCommand
FOR EACH ROW
BEGIN
    SET NEW.command_text = LOWER(TRIM(NEW.command_text));
    SET NEW.execution_status = 'PENDING';
END //

-- 2: auto inject default patient_id context after command inserted
CREATE TRIGGER after_insert_voicecommand
AFTER INSERT ON VoiceCommand
FOR EACH ROW
BEGIN
    INSERT INTO Context (command_id, context_type, context_value)
    VALUES (NEW.command_id, 'patient_id', '1');
END //

-- 3: block invalid status on update
CREATE TRIGGER before_update_voicecommand
BEFORE UPDATE ON VoiceCommand
FOR EACH ROW
BEGIN
    IF NEW.execution_status NOT IN ('PENDING', 'DONE', 'FAILED') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid execution status';
    END IF;
END //

DELIMITER ;
