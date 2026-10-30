USE sys_tools;

DROP PROCEDURE IF EXISTS sys_tools.mDyP;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE sys_tools.mDyP(
    IN target_schema VARCHAR(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
    IN target_table VARCHAR(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE curr_table VARCHAR(64);
    DECLARE target_date DATE;
    DECLARE v_partition_name VARCHAR(64);
    DECLARE partition_limit VARCHAR(30);

    -- Cursore per selezionare le tabelle partizionate
    DECLARE cur_tables CURSOR FOR 
        SELECT DISTINCT TABLE_NAME 
        FROM information_schema.PARTITIONS 
        WHERE BINARY TABLE_SCHEMA = BINARY target_schema 
          AND PARTITION_NAME IS NOT NULL
          AND (target_table IS NULL OR target_table = '' OR BINARY TABLE_NAME = BINARY target_table);

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET target_date = DATE_ADD(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH);
    SET partition_limit = DATE_ADD(target_date, INTERVAL 1 MONTH);

    OPEN cur_tables;

    read_loop: LOOP
        FETCH cur_tables INTO curr_table;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET v_partition_name = CONCAT(curr_table, '_', DATE_FORMAT(target_date, '%Y_%m'));

        -- Controllo ed eventuale creazione partizione
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.PARTITIONS
            WHERE BINARY TABLE_SCHEMA = BINARY target_schema
              AND BINARY TABLE_NAME = BINARY curr_table
              AND BINARY PARTITION_NAME = BINARY v_partition_name
        ) THEN
            SET @s = CONCAT(
                'ALTER TABLE `', target_schema, '`.`', curr_table, '` ',
                'ADD PARTITION (PARTITION `', v_partition_name, '` ',
                'VALUES LESS THAN (TO_DAYS(\'', partition_limit, ' 00:00:00\')))'
            );
            PREPARE stmt FROM @s;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;

    CLOSE cur_tables;
END //

DELIMITER ;