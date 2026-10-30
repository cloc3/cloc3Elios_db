# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="file di configurazione per la gestrione di un inverter fotovoltaico"

HOMEPAGE="http://github.com/cloc3/cloc3Elios_db"
LICENSE="GPL-3"
SLOT="0"

SRC_URI=""

KEYWORDS="~amd64 ~x86"
PROPERTIES="interactive"

DEPEND=""

RDEPEND="${DEPEND}
	app-misc/cloc3_inverter_db
	app-misc/cloc3_meter_db
	app-misc/cloc3_flussi_db
	app-misc/cloc3_storage_db
"

S="${WORKDIR}"

src_unpack(){
	mkdir -p "${S}"
}

src_install() {
	default
	doconfd "${FILESDIR}"/etc/conf/cloc3Elios_db
	doinitd "${FILESDIR}"/etc/init.d/cloc3Elios_db
	doinitd "${FILESDIR}"/etc/init.d/mariadb-tunnel
	dodir /usr/share/cloc3Elios_db/meta/bin
	exeinto /usr/share/cloc3Elios_db/meta/bin
	doexe "${FILESDIR}"/usr/share/cloc3Elios_db/meta/bin/*
	dodir /usr/share/cloc3Elios_db/meta/sql
	insinto /usr/share/cloc3Elios_db/meta/sql
	doins -r "${FILESDIR}"/usr/share/cloc3Elios_db/meta/sql/*
	insinto /etc/mysql/mariadb.d
	doins "${FILESDIR}"/etc/mysql/mariadb.d/*
}

pkg_config() {
	PATH="$PATH:/usr/share/cloc3Elios_db/meta/bin"
	creaCloc3EliosDb.sh
}
