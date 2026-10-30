USE cloc3Elios_db;

CREATE TABLE IF NOT EXISTS datiStorage (
		ts_inverter DATETIME NOT NULL,													-- trasmesso dall'inverter
		ts_server DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,	-- generato dall'asrock
		errorCode SMALLINT UNSIGNED NOT NULL,
		Capacity_Maximum SMALLINT UNSIGNED NOT NULL,						-- (Wh)
		Current_DC SMALLINT NOT NULL,														-- Corrente DC (A)
		Enable TINYINT UNSIGNED NOT NULL,
		StateOfCharge_Relative TINYINT UNSIGNED NOT NULL,				-- SOC % (0-100)
		Status_BatteryCell TINYINT UNSIGNED NOT NULL,
		Temperature_Cell TINYINT UNSIGNED NOT NULL,							-- Temperatura (° Fahrenheit !!)
		Voltage_DC SMALLINT UNSIGNED NOT NULL,									-- Tensione DC (V)
		PRIMARY KEY (ts_inverter, ts_server),
		KEY idx_ts_server (ts_server)
) ENGINE=InnoDB
PARTITION BY RANGE (TO_DAYS(ts_server)) (
		PARTITION datiStorage_2026_05 VALUES LESS THAN (TO_DAYS('2026-06-01')),
		PARTITION datiStorage_2026_06 VALUES LESS THAN (TO_DAYS('2026-07-01'))
);
