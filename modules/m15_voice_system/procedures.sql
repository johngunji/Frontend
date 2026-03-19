DELIMITER //

DROP PROCEDURE IF EXISTS ExecuteCommand //

CREATE PROCEDURE ExecuteCommand(IN p_command TEXT)
proc: BEGIN
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_patient_id INT;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    -- Step 1: Match template (priority to longer keywords)
    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE p_command REGEXP keyword
    ORDER BY LENGTH(keyword) DESC
    LIMIT 1;

    -- Step 2: If no template found
    IF v_template_id IS NULL THEN
        SELECT 'Command not supported' AS error;
        LEAVE proc;
    END IF;

    -- Step 3: Get SQL query
    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct 
        ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    -- Step 4: Validate SQL
    IF v_sql IS NULL THEN
        SELECT 'SQL mapping missing' AS error;
        LEAVE proc;
    END IF;

    -- Step 5: Extract patient_id from command
    SET v_patient_id = REGEXP_SUBSTR(p_command, '[0-9]+');

    IF v_patient_id IS NULL THEN
        SET v_patient_id = 1;
    END IF;

    -- Step 6: Replace placeholder
    SET v_final_sql = REPLACE(v_sql, ':patient_id', v_patient_id);

    -- Step 7: Execute dynamic SQL
    SET @query = v_final_sql;
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Step 8: Log execution
    INSERT INTO ExecutionLog (executed_query)
    VALUES (v_final_sql);

END //

DELIMITER ;
