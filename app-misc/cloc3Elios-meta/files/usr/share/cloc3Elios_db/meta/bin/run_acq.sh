export WORKDIR="/dev/shm/cloc3Elios_db"

if [[ -d "${WORKDIR}" ]]; then rm -rf "${WORKDIR}";fi
cp -a /usr/share/cloc3Elios_db /dev/shm/
>${WORKDIR}/last_TOTAL_ENERGY.txt
echo 0 > ${WORKDIR}/new_Energy.txt

echo "In attesa che MariaDB sia pronto a ricevere connessioni..."
while ! mariadb-admin ping -u "${USER}" -p"$(<${HOME}/.secret/${USER})" --connect-timeout=2 >/dev/null 2>&1; do
    echo "MariaDB non risponde, aspetto 3 secondi..."
    sleep 3
done
echo "MariaDB è sveglio! Avvio il ciclo di acquisizione."

inverterPATH="${PATH}:${WORKDIR}/inverter/bin"
meterPATH="${PATH}:${WORKDIR}/meter/bin"
fluxesPATH="${PATH}:${WORKDIR}/flussi/bin"
storagePATH="${PATH}:${WORKDIR}/storage/bin"

function run() {
	export PATH=${1}
	echo "PATH: ${PATH}"
	RAW_DATA=$(getRemoteData.sh)

	# controllo sui dati
	if [ $? -ne 0 ] || [ -z "${RAW_DATA}" ]; then
		return 1 2>/dev/null || exit 1
	fi

	WORKDIR="${WORKDIR}" makeMysqlStatement.sh ${RAW_DATA} | mariadb --connect-timeout=5 -u "${USER}" -p"$(<${HOME}/.secret/${USER})"
	if [[ $? != 0 ]]; then {
		#il codice di errore è il contenuto della prima sottostringa delimitata da '\n'
		errorCode=${RAW_DATA%%$'\n'*}
		if [[ ${errorCode} != 0 ]]; then {
			RAW_DATA=${RAW_DATA#$'\n'}	#elimino la prima riga, che già conosco.
			ts_inverter=${RAW_DATA%%$'\n'*}
			reason=$(sed -n 's/^reason: //p' <<< "${RAW_DATA}")
			userMessage=$(sed -n 's/^userMessage: //p' <<< "${RAW_DATA}")
			# trasemtto lo statement a mariadb in modalità 'here document'
			mariadb --connect-timeout=5 -u ${USER} -p"$(<${HOME}/.secret/${USER})" <<-EOF
				USE cloc3Elios_db;
				INSERT INTO rilevazioneErrori
				(ts_inverter, nomeTabella, errorCode, reason, user_message)
				VALUES
				('${ts_inverter}', '${2}', '${errorCode}', '${reason}', '${userMessage}' );
			EOF
		} fi
	} fi
}

counter=0
while true; do
	run ${inverterPATH} "osservabiliIstantaneeInverter"
	sleep 2
	run ${fluxesPATH} "flussiDiPotenza"
	sleep 2
	run ${meterPATH} "osservabiliIstantaneeSmartMeter"
	sleep 2
	((counter++))
	if (( counter % 7 == 0 )); then {
		run ${storagePATH} "datiStorage"
		counter = 0
		sleep 3
	} fi
	sleep 3
done
