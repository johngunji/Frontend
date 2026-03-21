DELIMITER //

DROP PROCEDURE IF EXISTS ExecuteCommand //

CREATE PROCEDURE ExecuteCommand(IN p_command TEXT)
proc: BEGIN
    DECLARE v_command_id INT;
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_value INT;
    DECLARE v_conditions TEXT DEFAULT '';
    DECLARE v_diagnosis VARCHAR(100) DEFAULT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- normalize input
    SET p_command = LOWER(TRIM(p_command));

    -- store the command
    INSERT INTO VoiceCommand (command_text, execution_status)
    VALUES (p_command, 'PENDING');
    SET v_command_id = LAST_INSERT_ID();

    -- SAFETY NET 1: Block Destructive Commands
    IF p_command LIKE '%drop%' OR p_command LIKE '%delete%' OR p_command LIKE '%update%' THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Destructive commands are not allowed'
        WHERE command_id = v_command_id;
        SELECT 'Destructive commands are not allowed' AS error;
        LEAVE proc;
    END IF;

    SET @best_template = NULL;
    SET @best_score = 0;

    -- BULLETPROOF SCORING LOGIC
    SELECT template_id,
    (
        (CONCAT(' ', p_command, ' ') LIKE CONCAT('% ', SUBSTRING_INDEX(keyword, ',', 1), ' %')) * 3 +
        (CONCAT(' ', p_command, ' ') LIKE CONCAT('% ', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 2), ',', -1), ' %')) * 2 +
        (CONCAT(' ', p_command, ' ') LIKE CONCAT('% ', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 3), ',', -1), ' %')) * 2 +
        (CONCAT(' ', p_command, ' ') LIKE CONCAT('% ', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 4), ',', -1), ' %')) * 2 +
        (CASE WHEN REGEXP_SUBSTR(p_command, '[0-9]+') IS NOT NULL THEN 2 ELSE 0 END) +
        (CASE WHEN p_command LIKE '%count%' AND command_type = 'Calculation' THEN 10 ELSE 0 END) +
        (CASE WHEN (p_command LIKE '%diabet%' OR p_command LIKE '%hypertens%' OR p_command LIKE '%fever%' OR p_command LIKE '%asthma%' OR p_command LIKE '%cardiac%' OR p_command LIKE '%thyroid%') AND template_pattern LIKE '%diagnosis%' THEN 50 ELSE 0 END) +
        -- NEW FIX: Explicit routing for M14 Lab modules
        (CASE WHEN (p_command LIKE '%lab%' OR p_command LIKE '%test%') AND template_pattern = 'patient lab results' THEN 40 ELSE 0 END) +
        (CASE WHEN p_command LIKE '%trend%' AND template_pattern = 'patient lab trends' THEN 60 ELSE 0 END)
    ) AS score
    INTO @best_template, @best_score
    FROM CommandTemplate
    ORDER BY score DESC, template_id ASC
    LIMIT 1;

    SET v_template_id = @best_template;

    -- SAFETY NET 2: Strict Minimum Score Threshold
    IF v_template_id IS NULL OR @best_score < 3 THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Command not recognised'
        WHERE command_id = v_command_id;
        SELECT 'Command not recognised. Try: patient 1, all patients, diabetic patients, pending bills, visits 1, doctors' AS error;
        LEAVE proc;
    END IF;

    UPDATE VoiceCommand SET template_id = v_template_id WHERE command_id = v_command_id;

    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    IF v_sql IS NULL THEN
        UPDATE VoiceCommand SET execution_status = 'FAILED', response_text = 'SQL mapping missing' WHERE command_id = v_command_id;
        SELECT 'SQL mapping missing' AS error;
        LEAVE proc;
    END IF;

    SET @temp_value = REGEXP_SUBSTR(p_command, '[0-9]+');
    IF @temp_value IS NULL OR @temp_value = '' THEN
        SET v_value = NULL;
    ELSE
        SET v_value = CAST(@temp_value AS UNSIGNED);
    END IF;

    IF v_value IS NOT NULL THEN
        INSERT INTO Context (command_id, context_type, context_value) VALUES (v_command_id, 'patient_id', v_value);
    END IF;

    -- extract diagnosis
    IF p_command LIKE '%diabet%'    THEN SET v_diagnosis = 'diabetes'; END IF;
    IF p_command LIKE '%hypertens%' THEN SET v_diagnosis = 'hypertension'; END IF;
    IF p_command LIKE '%fever%'     THEN SET v_diagnosis = 'fever'; END IF;
    IF p_command LIKE '%asthma%'    THEN SET v_diagnosis = 'asthma'; END IF;
    IF p_command LIKE '%cardiac%'   THEN SET v_diagnosis = 'cardiac'; END IF;
    IF p_command LIKE '%thyroid%'   THEN SET v_diagnosis = 'thyroid'; END IF;
    IF p_command LIKE '%migraine%'  THEN SET v_diagnosis = 'migraine'; END IF;
    IF p_command LIKE '%pneumonia%' THEN SET v_diagnosis = 'pneumonia'; END IF;

    -- build conditions
    SET v_conditions = '';
    IF p_command LIKE '%above%' AND v_value IS NOT NULL THEN
        SET v_conditions = CONCAT(v_conditions, ' AND age > ', v_value);
    ELSEIF p_command LIKE '%below%' AND v_value IS NOT NULL THEN
        SET v_conditions = CONCAT(v_conditions, ' AND age < ', v_value);
    END IF;

    IF p_command LIKE '%female%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND gender = 'Female'");
    ELSEIF p_command LIKE '% male%' OR p_command LIKE 'male%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND gender = 'Male'");
    END IF;

    IF p_command LIKE '%unpaid%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND payment_status = 'Pending'");
    END IF;

    SET v_final_sql = REPLACE(v_sql, ':conditions', v_conditions);

    IF v_value IS NOT NULL THEN
        SET v_final_sql = REPLACE(v_final_sql, ':patient_id', v_value);
        SET v_final_sql = REPLACE(v_final_sql, ':value', v_value);
    END IF;

    IF v_diagnosis IS NOT NULL THEN
        SET v_final_sql = REPLACE(v_final_sql, ':diagnosis', v_diagnosis);
    END IF;

    -- SAFETY NET 3: Catch unreplaced placeholders
    IF v_final_sql LIKE '%:%' THEN
        UPDATE VoiceCommand SET execution_status = 'FAILED', response_text = 'Missing required parameter' WHERE command_id = v_command_id;
        SELECT 'Error: Command is missing a required parameter.' AS error;
        LEAVE proc;
    END IF;

    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    INSERT INTO ExecutionLog (command_id, executed_query) VALUES (v_command_id, v_final_sql);

    UPDATE VoiceCommand SET execution_status = 'DONE', response_text = v_final_sql WHERE command_id = v_command_id;

END //

DELIMITER ;
