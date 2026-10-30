#!/bin/bash
# Usiamo "$@" per gestire tutti i parametri o assegniamoli con cura
ERR="$1"
TS_INV="$2 $3" # Unisce data e ora che arrivano come primo e secondo parametro
IAC="$4"
IDC="$5"
IDC_2="$6"
PAC="$7"
SAC="$8"
UAC="$9"
UDC="${10}"
UDC_2="${11}"

echo "
USE cloc3Elios_db;
INSERT INTO osservabiliIstantaneeInverter 
(ts_inverter, errorCode, IAC, IDC, IDC_2, PAC, SAC, UAC, UDC, UDC_2) 
VALUES
('$TS_INV', $ERR, $IAC, $IDC, $IDC_2, $PAC, $SAC, $UAC, $UDC, $UDC_2);"
