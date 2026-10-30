USE cloc3Elios_db;

-- 2. Costruzione dinamica della query di creazione con le partizioni automatiche
SET @sql_query = CONCAT('
	CREATE TABLE IF NOT EXISTS osservabiliIstantaneeSmartMeter (
		ts_inverter DATETIME NOT NULL,
		ts_server DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		errorCode SMALLINT UNSIGNED NOT NULL,
		IAC SMALLINT NOT NULL,				-- Current_AC_SUM
		PAS SMALLINT UNSIGNED NOT NULL,					-- PowerApparent_S_Sum
		PFS SMALLINT NOT NULL,					-- PowerFactor_Sum
		PRQ_S SMALLINT NOT NULL,					-- PowerReactive_Q_Sum
		PRP_S SMALLINT NOT NULL,					-- PowerReal_P_Sum (Potenza attiva)
		UAC SMALLINT UNSIGNED NOT NULL,				-- Voltage_AC_Phase_1
		FREQ SMALLINT UNSIGNED NOT NULL,				-- Voltage_AC_Phase_1
		PRIMARY KEY (ts_inverter, ts_server),
		KEY idx_ts_server (ts_server)
	) ENGINE=InnoDB
	PARTITION BY RANGE (TO_DAYS(ts_server)) (
        PARTITION osservabiliIstantaneeSmartMeter_', DATE_FORMAT(NOW(), '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y-%m-01'), '\')),
        PARTITION osservabiliIstantaneeSmartMeter_', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 2 MONTH, '%Y-%m-01'), '\'))
    );
');

-- 3. Compilazione ed esecuzione della stringa SQL appena generata
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

