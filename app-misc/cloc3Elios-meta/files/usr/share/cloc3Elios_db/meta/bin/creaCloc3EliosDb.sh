#!/bin/bash

WORKDIR="/usr/share/cloc3Elios_db"

# controlla se il server è attivo.
rc-service mysql status >/dev/null 2>&1
if [[ ${?} != 0 ]]; then {
	echo -e "server spento.\nUscita.";
	exit 1
} fi

#Verifica se ildatabase è già presente.
echo -en "digita la password di root del database:\n[ENTER PWD]: "
read -s ROOTPASS
echo ""|mariadb -uroot -p${ROOTPASS} 2>/dev/null
if [[ ${?} != 0 ]]; then {
	echo "password di root non valida.\nUscita"
	exit 2
} fi
dataBase="cloc3Elios_db"

echo -en "sceglii il nome utente amministratore e premi\n[ENTER USER]: "
read USER
if [[ $USER == "root" ]]; then {
	echo -e "non utilizzare l'utente 'root'\nUscita.";
	exit 4;
} fi

USERINFO=$(getent passwd ${USER})
USERDIR="$(echo ${USERINFO}|rev|cut -d: -f2|rev)"
if [[ !$? == 0 ]]; then {
	echo -e "l'utente $USER non esiste.\nUscita."
	exit 5;
} fi
if [[ ${USERINFO##*:} != "/bin/bash" ]];then {
	echo "l'utente ${USER} non è un utente semplice di sistema.\nUscita."
	exit 6
} fi

#verifica se l'utente possiede una cartella ~/.secret correttamente impostata
if [[ ! -d ${USERDIR}/.secret ]]; then 
	mkdir  -m 700 ${USERDIR}/.secret;
 else
 	if [[ $(stat -L -c '%a' ${USERDIR}/.secret) != '700' ]]; then
		echo -e "la cartella ${USERDIR}/.secret non ha permessi 700;\nUscita.";
		exit 7
	fi
 fi;

#Procede alla creazione dell'utente amministratore del database
echo -en "digita la password che verrrà memorizzata nel file ${USERDIR}/.secret/${USER}:\n[ENTER PWD]: "
read -s PASSWORD

echo ${PASSWORD} > ${USERDIR}/.secret/${USER}
chmod 600 ${USERDIR}/.secret/${USER}
chown -R ${USER}:${USER} ${USERDIR}/.secret

sed -i 's/^cloc3EliosUser.*/cloc3EliosUser="'${USER}'"/' /etc/conf.d/cloc3Elios_db
#genera il database
echo "CREATE DATABASE IF NOT EXISTS ${dataBase};"|mariadb -uroot -p${ROOTPASS}
echo "CREATE USER IF NOT EXISTS '${USER}'@'localhost' IDENTIFIED BY '$(<${USERDIR}/.secret/${USER})';"|mariadb -uroot -p${ROOTPASS}
echo "GRANT ALL PRIVILEGES ON ${dataBase}.* TO ${USER}@localhost;"|mariadb -uroot -p${ROOTPASS}

#-- 1. Permesso globale per lo streaming del BinLog (indispensabile)
if [[ ! -f ${USERDIR}/.secret/${USER}_replica ]]; then
    dd if=/dev/random bs=1 count=16 2>/dev/null | hexdump -e '16/1 "%02x" "\n"' > ${USERDIR}/.secret/${USER}_replica
fi
chmod 600 ${USERDIR}/.secret/${USER}_replica
chown ${USER}:${USER} ${USERDIR}/.secret/${USER}_replica

echo "CREATE USER IF NOT EXISTS 'cloc3_replica'@'127.0.0.1' IDENTIFIED BY '$(<${USERDIR}/.secret/${USER}_replica)';"|mariadb -uroot -p${ROOTPASS}
echo "GRANT REPLICATION SLAVE ON *.* TO 'cloc3_replica'@'127.0.0.1';"|mariadb -uroot -p${ROOTPASS}
#-- 2. Permesso esplicito di sola lettura (SELECT) su sys_tools per la replica
echo "GRANT SELECT ON cloc3Elios_db.* TO 'cloc3_replica'@'127.0.0.1';"|mariadb -uroot -p${ROOTPASS}
echo "GRANT SELECT ON sys_tools.* TO 'cloc3_replica'@'127.0.0.1';"|mariadb -uroot -p${ROOTPASS}

#crea la tabella delle partizioni
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/inverter/sql/tabellaOsservabiliIstantaneeInverter.sql
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/meter/sql/tabellaOsservabiliIstantaneeSmartMeter.sql
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/flussi/sql/tabellaFlussiDiPotenza.sql
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/storage/sql/tabellaDatiStorage.sql
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/meta/sql/tabellaDatiCumulativi.sql
#imposta la routine di partizionamento
echo "CREATE DATABASE IF NOT EXISTS sys_tools;"|mariadb -uroot -p${ROOTPASS}
mariadb -uroot -p${ROOTPASS} < ${WORKDIR}/db_utils/sql/monthlyDynamicPartitioning.sql
#genera l'evento per il partizionamento automatico
mariadb -uroot -p${ROOTPASS} < ${WORKDIR}/db_utils/sql/creaEvento.sql

#genera la tabella rilevazioneErrori
mariadb -u${USER} -p$(<${USERDIR}/.secret/${USER}) < ${WORKDIR}/meta/sql/tabellaRilevazioneErrori.sql

rc-service mysql restart
rc-update add cloc3Elios_db default
rc-service cloc3Elios_db start
