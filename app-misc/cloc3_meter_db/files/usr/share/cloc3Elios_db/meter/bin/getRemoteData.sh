#!/bin/bash
URL="http://inverter/solar_api/v1/GetMeterRealtimeData.cgi?Scope=Device&DeviceId=0"
if [[ "$(<${WORKDIR}/new_Energy.txt)" == "0" ]]; then {
	parseString='
		.Head.Status.Code,
		.Head.Timestamp as $ts | 
		( $ts | sub("T"; " ") | sub("[+Z].*"; "") ),
		(.Body.Data | 
			(.Current_AC_Sum * 100		| floor),	# Corrente AC: 2 decimali (es. 1.15 -> 115)
			(.PowerApparent_S_Sum			| floor),	# Potenza Apparente: intero (Watt)
			(.PowerFactor_Sum * 1000	| round),	# cos(phi) adimensionale minore di uno
			(.PowerReactive_Q_Sum			| floor),	# Potenza Rettiva: intero (Watt)
			(.PowerReal_P_Sum					| floor),	# Potenza Reale: intero (Watt)
			(.Voltage_AC_Phase_1 * 10	| floor),	# Tensione AC: 1 decimale (es. 230.5 -> 2305)
			(.Frequency_Phase_Average * 100 | floor)	# (Hz) 
		),
		(.Head.Status |
			("reason: "+.Reason | gsub ("\n|\r";" ")  | .[0:255]),					# codice di errore
			("userMessage: "+.UserMessage | gsub ("\n|\r";" ")  | .[0:255])	# commento errore
		)
	'
} else {
	parseString='
    .Head.Status.Code,
    .Head.Timestamp as $ts | 
    ( $ts | sub("T"; " ") | sub("[+Z].*"; "") ),
    (.Body.Data | 
      (.Current_AC_Sum * 100    | floor), 	# Corrente AC: 2 decimali (es. 1.15 -> 115)
      (.PowerApparent_S_Sum     | floor), 	# Potenza Apparente: intero (Watt)
      (.PowerFactor_Sum * 1000  | round), 	# cos(phi) adimensionale minore di uno
      (.PowerReactive_Q_Sum     | floor), 	# Potenza Rettiva: intero (Watt)
      (.PowerReal_P_Sum         | floor), 	# Potenza Reale: intero (Watt)
      (.Voltage_AC_Phase_1 * 10 | floor),		# Tensione AC: 1 decimale (es. 230.5 -> 2305)
			(.Frequency_Phase_Average * 100 | floor),	# (Hz) 
			(.EnergyReactive_VArAC_Sum_Consumed	| floor),	# energia reattiva assorbita internamente (reattiva) (VAH)
			(.EnergyReactive_VArAC_Sum_Produced	| floor),	# energia reattiva emessa verso la rete esterna (capacitiva) (VAH)
			(.EnergyReal_WAC_Sum_Consumed 			| floor),	# energia reale assorbita, imessa nella rete esterna (Wh)
			(.EnergyReal_WAC_Sum_Produced  			| floor)	# energia reale prodotta ed emessa verso la rete esterna (Wh)
    ),
    (.Head.Status |
      ("reason: "+.Reason | gsub ("\n|\r";" ")  | .[0:255]),          # codice di errore
      ("userMessage: "+.UserMessage | gsub ("\n|\r";" ")  | .[0:255]) # commento errore
    )
  '
} fi

# Controllo di ricezione
REMOTE_ANSWER=$(GET -t1 "${URL}")
if [[ $? -ne 0 || -z ${REMOTE_ANSWER} ]]; then {
	return 1 2>/dev/null || exit 1
} else {
	echo "${REMOTE_ANSWER}"|jq -r "${parseString}"
} fi
