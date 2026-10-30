USE cloc3Elios_db;

-- 2. Costruzione dinamica della query di creazione con le partizioni automatiche
SET @sql_query = CONCAT('
	CREATE TABLE IF NOT EXISTS osservabiliIstantaneeInverter (
		ts_inverter DATETIME NOT NULL,
		ts_server DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
		errorCode SMALLINT UNSIGNED NOT NULL,
		IAC SMALLINT UNSIGNED NOT NULL,
		IDC SMALLINT UNSIGNED NOT NULL,
		IDC_2 SMALLINT UNSIGNED NOT NULL,
		PAC SMALLINT UNSIGNED NOT NULL,
		SAC SMALLINT UNSIGNED NOT NULL,
		UAC SMALLINT UNSIGNED NOT NULL,
		UDC SMALLINT UNSIGNED NOT NULL,
		UDC_2 SMALLINT UNSIGNED NOT NULL,
		PRIMARY KEY (ts_inverter, ts_server),
		KEY idx_ts_server (ts_server)
	) ENGINE=InnoDB
    PARTITION BY RANGE (TO_DAYS(ts_server)) (
        PARTITION osservabiliIstantaneeInverter_', DATE_FORMAT(NOW(), '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y-%m-01'), '\')),
        PARTITION osservabiliIstantaneeInverter_', DATE_FORMAT(NOW() + INTERVAL 1 MONTH, '%Y_%m'), ' VALUES LESS THAN (TO_DAYS(\'', DATE_FORMAT(NOW() + INTERVAL 2 MONTH, '%Y-%m-01'), '\'))
    );
');

-- 3. Compilazione ed esecuzione della stringa SQL appena generata
PREPARE stmt FROM @sql_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

