#!/bin/bash
URL="http://inverter/solar_api/v1/GetPowerFlowRealtimeData.fcgi"
parseString='
  .Head.Status.Code,
  .Head.Timestamp as $ts | 
  ( $ts | sub("T"; " ") | sub("[+Z].*"; "") ),
    ( .Body.Data.Inverters["1"] |
        ((.E_Total // 0) | floor),    # Energia Totale erogata in AC
        ((.P // 0)       | floor),    # Potenza immessa dall inverter (in alternata) (Watt)
        ((.SOC // 0)     | floor)     # percentuale di carica della batteria
    ),
    ( .Body.Data.Site    |
        ((.P_Akku // 0)   | floor),   # Potenza accumulata (o ceduta) dalla batteria (Watt)
        ((.P_Grid // 0)   | floor),   # Potenza trasmessa alla rete (Watt)
        ((.P_Load // 0)   | floor),   # Potenza consumata internamente (Watt)
        ((.P_PV // 0)     | floor),   # Potenza prodotta dai pannelli (in continua) (Watt)
        (if .rel_Autonomy == null then null else (.rel_Autonomy | floor) end),         # percentuale di autonomia
        (if .rel_SelfConsumption == null then null else (.rel_SelfConsumption | floor) end) # percentuale di autoconsumo
    ),
  (.Head.Status |
    ("reason: "+.Reason | gsub ("\n|\r";" ")  | .[0:255]) ,         # codice di errore
    ("userMessage: "+.UserMessage | gsub ("\n|\r";" ")  | .[0:255])    # commento errore
  )
'
# Controllo di ricezione
REMOTE_ANSWER=$(GET -t1 "${URL}")
if [[ $? -ne 0 || -z ${REMOTE_ANSWER} ]]; then {
    return 1 2>/dev/null || exit 1
} else {
    echo "${REMOTE_ANSWER}"|jq -r "${parseString}"
} fi
