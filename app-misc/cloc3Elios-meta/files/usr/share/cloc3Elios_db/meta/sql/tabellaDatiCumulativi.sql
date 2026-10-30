USE cloc3Elios_db;

-- 1. Pulizia preventiva se decidi di azzerare tutto
-- DROP TABLE IF EXISTS energieCumulative;

-- 2. Costruzione dinamica della query di creazione con le partizioni automatiche
SET @sql_query = CONCAT('
    CREATE TABLE IF NOT EXISTS energieCumulative (
        ts_inverter DATETIME NOT NULL,
        ts_server DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        errorCode SMALLINT UNSIGNED NOT NULL,
        TOTAL_ENERGY INT UNSIGNED NOT NULL,
        EnergyReactive_VArAC_Sum_Consumed INT UNSIGNED NOT NULL,
        EnergyReactive_VArAC_Sum_Produced INT UNSIGNED NOT NULL,
        EnergyReal_WAC_Sum_Consumed INT UNSIGNED NOT NULL,
        EnergyReal_WAC_Sum_Produced INT UNSIGNED NOT NULL,
        PRIMARY KEY (ts_inverter, ts_server),
        KEY idx_ts_server (ts_server)
    ) ENGINE=InnoDB
    PARTITION BY RANGE (TO_DAYS(ts_server)) (
        PARTITION energieCumulative_', DATE_FORMAT(NOW(), '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y-%m-01'), '\')),
        PARTITION energieCumulative_', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 2 MONTH, '%Y-%m-01'), '\'))
    );
');

-- 3. Compilazione ed esecuzione della stringa SQL appena generata
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
