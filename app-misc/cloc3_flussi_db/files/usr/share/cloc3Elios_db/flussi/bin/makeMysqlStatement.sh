#!/bin/bash
ERR="$1"
TS_INV="$2 $3" # Unisce data e ora che arrivano come primo e secondo parametro
TOTAL_ENERGY="${4}"
PAC="$5"
SOC="$6"
P_Akku="$7"
P_Grid="$8"
P_Load="$9"
P_PV="${10}"
rel_Autonomy="${11}"
rel_SelfConsumption="${12}"

NEW_ENERGY="${WORKDIR}/new_Energy.txt"
FILE_ENERGY="${WORKDIR}/last_TOTAL_ENERGY.txt"
if [[ "${TOTAL_ENERGY}" != $(<"${FILE_ENERGY}") ]]; then
  echo "${TOTAL_ENERGY}" > "${FILE_ENERGY}"
	echo "1" > "${NEW_ENERGY}"
fi

echo "
USE cloc3Elios_db;
INSERT INTO flussiDiPotenza 
(ts_inverter, errorCode, PAC, SOC, P_Akku, P_Grid, P_Load, P_PV, rel_Autonomy, rel_SelfConsumption ) 
VALUES
('$TS_INV', $ERR, $PAC, $SOC, $P_Akku, $P_Grid, $P_Load, $P_PV, $rel_Autonomy, $rel_SelfConsumption );"
