USE m15;

DELIMITER //

DROP PROCEDURE IF EXISTS ExecuteCommand //

CREATE PROCEDURE ExecuteCommand(IN p_command TEXT)
BEGIN
    DECLARE v_template_id INT DEFAULT NULL;
    DECLARE v_sql TEXT;
    DECLARE v_final_sql TEXT;
    DECLARE v_patient_id INT DEFAULT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_template_id = NULL;

    SELECT template_id INTO v_template_id
    FROM CommandTemplate
    WHERE p_command REGEXP keyword
    LIMIT 1;

    IF v_template_id IS NULL THEN
        SELECT 'Command not supported' AS error_message;
        LEAVE BEGIN;
    END IF;

    SELECT sa.sql_query INTO v_sql
    FROM SQL_Action sa
    JOIN CommandTemplate ct 
        ON sa.sql_action_id = ct.sql_action_id
    WHERE ct.template_id = v_template_id
    LIMIT 1;

    IF v_sql IS NULL THEN
        SELECT 'SQL mapping missing' AS error_message;
        LEAVE BEGIN;
    END IF;

    SET v_patient_id = REGEXP_SUBSTR(p_command, '[0-9]+');

    IF v_patient_id IS NULL THEN
        SELECT 'Missing patient_id' AS error_message;
        LEAVE BEGIN;
    END IF;

    SET v_patient_id = CAST(v_patient_id AS UNSIGNED);

    SET v_final_sql = REPLACE(v_sql, ':patient_id', v_patient_id);

    SET @query = v_final_sql;

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;
