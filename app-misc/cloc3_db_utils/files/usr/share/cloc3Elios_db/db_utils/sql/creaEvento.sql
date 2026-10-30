USE sys_tools;

DELIMITER //

CREATE EVENT IF NOT EXISTS ev_auto_partition
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-07-28 23:00:00'
ON COMPLETION PRESERVE
DO
BEGIN
    -- Passando NULL elabora AUTOMATICAMENTE tutte le tabelle partizionate di cloc3Elios_db!
    CALL sys_tools.mDyP('cloc3Elios_db', NULL);
END //

DELIMITER ;
