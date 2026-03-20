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

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- normalize input
    SET p_command = LOWER(TRIM(p_command));

    -- store the command
    INSERT INTO VoiceCommand (command_text, execution_status)
    VALUES (p_command, 'PENDING');
    SET v_command_id = LAST_INSERT_ID();

    -- score each template, lowest template_id wins on tie
    SET @best_template = NULL;
    SET @best_score = 0;

    SELECT template_id,
(
   (p_command LIKE CONCAT('%', SUBSTRING_INDEX(keyword, ',', 1), '%')) +
   (p_command LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 2), ',', -1), '%')) +
   (p_command LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 3), ',', -1), '%')) +
   (p_command LIKE CONCAT('%', SUBSTRING_INDEX(SUBSTRING_INDEX(keyword, ',', 4), ',', -1), '%')) +

   -- 🔥 BONUS: number present → boost ID-based queries
   (CASE 
        WHEN REGEXP_SUBSTR(p_command, '[0-9]+') IS NOT NULL THEN 2 
        ELSE 0 
    END)

) AS score
INTO @best_template, @best_score
FROM CommandTemplate
ORDER BY score DESC, template_id ASC
LIMIT 1;

    SET v_template_id = @best_template;

    -- no match found
    IF v_template_id IS NULL OR @best_score = 0 THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Command not recognised'
        WHERE command_id = v_command_id;
        SELECT 'Command not recognised' AS error;
        LEAVE proc;
    END IF;

    -- link matched template to command
    UPDATE VoiceCommand
    SET template_id = v_template_id
    WHERE command_id = v_command_id;

    -- get the SQL for this template
    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    IF v_sql IS NULL THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'SQL mapping missing'
        WHERE command_id = v_command_id;
        SELECT 'SQL mapping missing' AS error;
        LEAVE proc;
    END IF;

    -- extract number from command if present
    SET @temp_value = REGEXP_SUBSTR(p_command, '[0-9]+');
    IF @temp_value IS NULL OR @temp_value = '' THEN
        SET v_value = NULL;
    ELSE
        SET v_value = CAST(@temp_value AS UNSIGNED);
    END IF;

    -- save number as context
    IF v_value IS NOT NULL THEN
        INSERT INTO Context (command_id, context_type, context_value)
        VALUES (v_command_id, 'patient_id', v_value);
    END IF;

    -- build dynamic conditions
    SET v_conditions = '';

    -- age filter
    IF p_command LIKE '%above%' AND v_value IS NOT NULL THEN
        SET v_conditions = CONCAT(v_conditions, ' AND age > ', v_value);
    ELSEIF p_command LIKE '%below%' AND v_value IS NOT NULL THEN
        SET v_conditions = CONCAT(v_conditions, ' AND age < ', v_value);
    END IF;

    -- gender filter (space before male to avoid matching female)
    IF p_command LIKE '%female%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND gender = 'Female'");
    ELSEIF p_command LIKE '% male%' OR p_command LIKE 'male%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND gender = 'Male'");
    END IF;

    -- billing filter
    IF p_command LIKE '%unpaid%' THEN
        SET v_conditions = CONCAT(v_conditions, " AND payment_status = 'Pending'");
    END IF;

    -- replace placeholders
    SET v_final_sql = REPLACE(v_sql, ':conditions', v_conditions);

    IF v_value IS NOT NULL THEN
        SET v_final_sql = REPLACE(v_final_sql, ':patient_id', v_value);
        SET v_final_sql = REPLACE(v_final_sql, ':value', v_value);
    END IF;

    -- execute the query
    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- log what ran
    INSERT INTO ExecutionLog (command_id, executed_query)
    VALUES (v_command_id, v_final_sql);

    -- mark as done
    UPDATE VoiceCommand
    SET execution_status = 'DONE',
        response_text = v_final_sql
    WHERE command_id = v_command_id;

END //

DELIMITER ;
