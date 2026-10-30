#!/bin/bash
# Usiamo "$@" per gestire tutti i parametri o assegniamoli con cura
ERR="$1"
TS_INV="$2 $3" # Unisce data e ora che arrivano come primo e secondo parametro
Capacity_Maximum="$4"
Current_DC="$5"
Enable="$6"
StateOfCharge_Relative="$7"
Status_BatteryCell="$8"
Temperature_Cell="$9"
Voltage_DC="${10}"

echo "
USE cloc3Elios_db;
INSERT INTO datiStorage 
(ts_inverter, errorCode, Capacity_Maximum, Current_DC, Enable, StateOfCharge_Relative, Status_BatteryCell, Temperature_Cell, Voltage_DC) 
VALUES
('$TS_INV', $ERR, $Capacity_Maximum, $Current_DC, $Enable, $StateOfCharge_Relative, $Status_BatteryCell, $Temperature_Cell, $Voltage_DC );"
