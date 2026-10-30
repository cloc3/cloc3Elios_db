USE cloc3Elios_db;

-- 2. Costruzione dinamica della query di creazione con le partizioni automatiche
SET @sql_query = CONCAT('
	CREATE TABLE IF NOT EXISTS flussiDiPotenza (
		ts_inverter DATETIME NOT NULL,
		ts_server DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		errorCode SMALLINT UNSIGNED NOT NULL,
		PAC SMALLINT NOT NULL,
		SOC TINYINT NOT NULL,
		P_Akku SMALLINT NOT NULL,
		P_Grid SMALLINT NOT NULL,
		P_Load SMALLINT NOT NULL,
		P_PV SMALLINT NOT NULL,
		rel_Autonomy TINYINT UNSIGNED,
		rel_SelfConsumption TINYINT UNSIGNED,
		PRIMARY KEY (ts_inverter, ts_server),
		KEY idx_ts_server (ts_server)
	) ENGINE=InnoDB
	PARTITION BY RANGE (TO_DAYS(ts_server)) (
		PARTITION flussiDiPotenza_', DATE_FORMAT(NOW(), '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y-%m-01'), '\')),
		PARTITION flussiDiPotenza_', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 2 MONTH, '%Y-%m-01'), '\'))
    );
');

-- 3. Compilazione ed esecuzione della stringa SQL appena generata
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
