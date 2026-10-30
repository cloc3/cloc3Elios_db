# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="file di configurazione per la gestione di un inverter fotovoltaico"

HOMEPAGE="http://github.com/cloc3/cloc3Elios_db"
LICENSE="GPL-3"
SLOT="0"

SRC_URI=""

KEYWORDS="~amd64 ~x86"
PROPERTIES="interactive"

DEPEND=""

RDEPEND="${DEPEND}
	app-misc/cloc3_db_utils
	dev-perl/libwww-perl
	app-misc/jq
	dev-db/mariadb
"
S="${WORKDIR}"

src_unpack(){
	mkdir -p "${S}"
}

src_install() {
	default
	dodir /usr/share/cloc3Elios_db/flussi/bin
	exeinto /usr/share/cloc3Elios_db/flussi/bin
	doexe "${FILESDIR}"/usr/share/cloc3Elios_db/flussi/bin/*
	dodir /usr/share/cloc3Elios_db/sql
	insinto /usr/share/cloc3Elios_db/flussi/sql
	doins -r "${FILESDIR}"/usr/share/cloc3Elios_db/flussi/sql/*
}
