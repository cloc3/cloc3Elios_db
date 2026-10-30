#!/bin/bash
URL="http://inverter/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DataCollection=CommonInverterData"
parseString='
  .Head.Status.Code,
  .Head.Timestamp as $ts | 
  ( $ts | sub("T"; " ") | sub("[+Z].*"; "") ),
  (.Body.Data | 
    (.IAC.Value   * 100 | floor),  # Corrente AC: 2 decimali (es. 1.15 -> 115)
    (.IDC.Value   * 100 | floor),  # Corrente DC 1: 2 decimali
    (.IDC_2.Value * 100 | floor),  # Corrente DC 2: 2 decimali
    (.PAC.Value   | floor),        # Potenza AC: intero (Watt)
    (.SAC.Value   | floor),        # Potenza Apparente: intero (VA)
    (.UAC.Value   * 10  | floor),  # Tensione AC: 1 decimale (es. 230.5 -> 2305)
    (.UDC.Value   * 10  | floor),  # Tensione DC 1: 1 decimale
    (.UDC_2.Value * 10  | floor)   # Tensione DC 2: 1 decimale
  ),
  (.Head.Status |
    ("reason: "+.Reason | gsub ("\n|\r";" ")  | .[0:255]) ,		# codice di errore
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
