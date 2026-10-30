#!/bin/bash
URL="http://inverter/solar_api/v1/GetStorageRealtimeData.cgi?Scope=Device&DeviceId=0"
parseString='
  .Head.Status.Code,
  .Head.Timestamp as $ts | 
  ( $ts | sub("T"; " ") | sub("[+Z].*"; "") ),
  (.Body.Data.Controller | 
    (.Capacity_Maximum				| floor),		# (Wh)
    (.Current_DC * 100				| floor),		# Corrente DC (A): 2 decimali
    (.Enable									| floor),		# Corrente DC : 2 decimali
    (.StateOfCharge_Relative	| floor), 	# SOC % (0-100)
    (.Status_BatteryCell			| floor),
    (.Temperature_Cell   			| floor ),	# (°F alla barba dell AI)
    (.Voltage_DC* 10  				| floor)		# Tensione DC: 1 decimale
  ),
  (.Head.Status |
    ("reason: "+.Reason | gsub ("\n|\r";" ")  | .[0:255]) ,					# codice di errore
    ("userMessage: "+.UserMessage | gsub ("\n|\r";" ")  | .[0:255])	# commento errore
  )
'
# Controllo di ricezione
REMOTE_ANSWER=$(GET -t1 "${URL}")
if [[ $? -ne 0 || -z ${REMOTE_ANSWER} ]]; then {
	return 1 2>/dev/null || exit 1
} else {
	echo "${REMOTE_ANSWER}"|jq -r "${parseString}"
} fi
