#!/bin/bash
# Usiamo "$@" per gestire tutti i parametri o assegniamoli con cura
ERR="$1"
TS_INV="$2 $3" # Unisce data e ora che arrivano come primo e secondo parametro
IAC="$4"
PAS="$5"
PFS="$6"
PRQ_S="$7"
PRP_S="$8"
UAC="$9"
FREQ="${10}"

echo "
USE cloc3Elios_db;
INSERT INTO osservabiliIstantaneeSmartMeter
(ts_inverter, errorCode, IAC, PAS, PFS, PRQ_S, PRP_S, UAC, FREQ) 
VALUES
('$TS_INV', $ERR, $IAC, $PAS, $PFS, $PRQ_S, $PRP_S, $UAC, $FREQ);"

if [[ "$(<${WORKDIR}/new_Energy.txt)" == "1" ]]; then {
	EnergyReactive_VArAC_Sum_Consumed="${11}"
	EnergyReactive_VArAC_Sum_Produced="${12}"
	EnergyReal_WAC_Sum_Consumed="${13}"
	EnergyReal_WAC_Sum_Produced="${14}"
	TOTAL_ENERGY="$(<"${WORKDIR}/last_TOTAL_ENERGY.txt")"
	echo "0" > "${WORKDIR}/new_Energy.txt"

	echo "
		USE cloc3Elios_db;
		INSERT INTO energieCumulative
		(ts_inverter, errorCode, TOTAL_ENERGY, EnergyReactive_VArAC_Sum_Consumed, EnergyReactive_VArAC_Sum_Produced, EnergyReal_WAC_Sum_Consumed, EnergyReal_WAC_Sum_Produced)
		VALUES
		('$TS_INV', $ERR, $TOTAL_ENERGY, $EnergyReactive_VArAC_Sum_Consumed, $EnergyReactive_VArAC_Sum_Produced, $EnergyReal_WAC_Sum_Consumed, $EnergyReal_WAC_Sum_Produced);"
} fi
