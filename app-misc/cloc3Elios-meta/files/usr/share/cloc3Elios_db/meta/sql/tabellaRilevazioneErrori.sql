USE cloc3Elios_db;

CREATE TABLE IF NOT EXISTS rilevazioneErrori (
    id INT AUTO_INCREMENT NOT NULL,
    ts_inverter DATETIME NOT NULL,
    nomeTabella VARCHAR(64),
    errorCode SMALLINT NOT NULL,
    reason VARCHAR(255) DEFAULT NULL,
    user_message VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB
