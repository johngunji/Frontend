
DELIMITER //

DROP PROCEDURE IF EXISTS ExecuteCommand //

CREATE PROCEDURE ExecuteCommand(IN p_command TEXT)
proc: BEGIN
    DECLARE v_command_id INT;
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_value INT;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- Step 1: normalize input
    SET p_command = LOWER(TRIM(p_command));

    -- Step 2: insert into VoiceCommand
    INSERT INTO VoiceCommand (command_text, execution_status)
    VALUES (p_command, 'PENDING');
    SET v_command_id = LAST_INSERT_ID();

    -- Step 3: match template using REGEXP, longer keywords win
    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE p_command REGEXP keyword
    ORDER BY LENGTH(keyword) DESC
    LIMIT 1;

    -- Step 4: no match
    IF v_template_id IS NULL THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Command not recognised'
        WHERE command_id = v_command_id;
        SELECT 'Command not recognised' AS error;
        LEAVE proc;
    END IF;

    -- Step 5: link template to command
    UPDATE VoiceCommand
    SET template_id = v_template_id
    WHERE command_id = v_command_id;

    -- Step 6: get SQL template
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

   -- Step 7: extract number safely
SET @temp_value = REGEXP_SUBSTR(p_command, '[0-9]+');

IF @temp_value IS NULL OR @temp_value = '' THEN
    SET v_value = NULL;
ELSE
    SET v_value = CAST(@temp_value AS UNSIGNED);
END IF;
SET v_final_sql = v_sql;

    IF v_value IS NOT NULL THEN
        SET v_final_sql = REPLACE(v_final_sql, ':patient_id', v_value);
        SET v_final_sql = REPLACE(v_final_sql, ':value', v_value);
    END IF;

    -- Step 8: inject context if available
    IF v_value IS NULL THEN
        SELECT context_value INTO v_value
        FROM Context
        WHERE command_id = v_command_id
          AND context_type = 'patient_id'
        LIMIT 1;

        IF v_value IS NOT NULL THEN
            SET v_final_sql = REPLACE(v_final_sql, ':patient_id', v_value);
        END IF;
    END IF;

    -- Step 9: execute
    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Step 10: log
    INSERT INTO ExecutionLog (command_id, executed_query)
    VALUES (v_command_id, v_final_sql);

    -- Step 11: mark done
    UPDATE VoiceCommand
    SET execution_status = 'DONE',
        response_text = v_final_sql
    WHERE command_id = v_command_id;

END //

DELIMITER ;
