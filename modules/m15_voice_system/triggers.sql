DELIMITER //

-- Trigger: Log all SQL actions inserted into SQL_Action
CREATE TRIGGER after_insert_sql_action
AFTER INSERT ON SQL_Action
FOR EACH ROW
BEGIN
    INSERT INTO ExecutionLog (executed_query)
    VALUES (CONCAT('New SQL action added: ', NEW.sql_query));
END//

DELIMITER ;
