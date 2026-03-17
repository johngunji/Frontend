DELIMITER //

CREATE PROCEDURE ExecuteCommand(IN p_command_id INT)
BEGIN
    DECLARE v_input TEXT;
    DECLARE v_template_id INT;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_patient_id VARCHAR(50);

    -- get command text
    SELECT command_text INTO v_input
    FROM VoiceCommand
    WHERE command_id = p_command_id;

    -- match template using keyword
    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE v_input LIKE CONCAT('%', keyword, '%')
    LIMIT 1;

    -- if no template found
    IF v_template_id IS NULL THEN
        UPDATE VoiceCommand
        SET execution_status = 'FAILED',
            response_text = 'Command not supported'
        WHERE command_id = p_command_id;

    ELSE

        -- store matched template
        UPDATE VoiceCommand
        SET template_id = v_template_id
        WHERE command_id = p_command_id;

        -- get SQL query
        SELECT sa.sql_query INTO v_sql
        FROM SQL_Action sa
        JOIN CommandTemplate ct ON sa.sql_action_id = ct.sql_action_id
        WHERE ct.template_id = v_template_id;

        -- get context (patient_id)
        SELECT context_value INTO v_patient_id
        FROM Context
        WHERE command_id = p_command_id
        AND context_type = 'patient_id'
        LIMIT 1;
        IF v_patient_id IS NULL THEN
        SET v_patient_id = '1';
    END IF;
        -- replace placeholder
        SET v_final_sql = REPLACE(v_sql, ':patient_id', v_patient_id);

        -- execute dynamic SQL
        SET @query = v_final_sql;
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

            -- log executed query
        INSERT INTO ExecutionLog (command_id, executed_query)
        VALUES (p_command_id, v_final_sql);

        -- update status
        UPDATE VoiceCommand
        SET execution_status = 'DONE',
            response_text = v_final_sql
        WHERE command_id = p_command_id;

    END IF;

END //

DELIMITER ;