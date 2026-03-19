DELIMITER //

DROP PROCEDURE IF EXISTS ExecuteCommand //

CREATE PROCEDURE ExecuteCommand(IN p_command TEXT)
proc: BEGIN
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_value INT;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- Match template (priority to longer keywords)
    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE p_command REGEXP keyword
    ORDER BY LENGTH(keyword) DESC
    LIMIT 1;

    IF v_template_id IS NULL THEN
        SELECT 'Command not supported' AS error;
        LEAVE proc;
    END IF;

    -- Get SQL
    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct 
        ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    IF v_sql IS NULL THEN
        SELECT 'SQL mapping missing' AS error;
        LEAVE proc;
    END IF;

    -- Extract number
    SET v_value = REGEXP_SUBSTR(p_command, '[0-9]+');

    SET v_final_sql = v_sql;

    IF v_value IS NOT NULL THEN
        SET v_final_sql = REPLACE(v_final_sql, ':patient_id', v_value);
        SET v_final_sql = REPLACE(v_final_sql, ':value', v_value);
    END IF;

    -- Execute
    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Log
    INSERT INTO ExecutionLog (executed_query)
    VALUES (v_final_sql);

END //

DELIMITER ;
