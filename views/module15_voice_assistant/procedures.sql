DELIMITER //

CREATE PROCEDURE ExecuteCommand(IN p_command_id INT)
proc: BEGIN
    DECLARE v_input TEXT;
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_patient_id VARCHAR(50);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- Step 1: Get command text
    SELECT command_text INTO v_input
    FROM VoiceCommand
    WHERE command_id = p_command_id
    LIMIT 1;

    -- Step 2: Match template
    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE v_input LIKE CONCAT('%', keyword, '%')
    LIMIT 1;

    -- Step 3: If no template
    IF v_template_id IS NULL THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Command not supported'
        WHERE command_id = p_command_id;

        LEAVE proc;
    END IF;

    -- Step 4: Store template
    UPDATE VoiceCommand
    SET template_id = v_template_id
    WHERE command_id = p_command_id;

    -- Step 5: Get SQL query
    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct 
        ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    -- Step 6: Validate SQL
    IF v_sql IS NULL THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'SQL mapping missing'
        WHERE command_id = p_command_id;

        LEAVE proc;
    END IF;

    -- Step 7: Get context
    SELECT context_value INTO v_patient_id
    FROM Context
    WHERE command_id = p_command_id
      AND context_type = 'patient_id'
    LIMIT 1;

    IF v_patient_id IS NULL THEN
        SET v_patient_id = '1';
    END IF;

    -- Security: enforce numeric
    SET v_patient_id = CAST(v_patient_id AS UNSIGNED);

    -- Step 8: Replace placeholder
    SET v_final_sql = REPLACE(v_sql, ':patient_id', v_patient_id);

    -- Step 9: Execute
    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Step 10: Log
    INSERT INTO ExecutionLog (command_id, executed_query)
    VALUES (p_command_id, v_final_sql);

    -- Step 11: Update status
    UPDATE VoiceCommand
    SET execution_status = 'DONE',
        response_text = v_final_sql
    WHERE command_id = p_command_id;

END //

DELIMITER ;