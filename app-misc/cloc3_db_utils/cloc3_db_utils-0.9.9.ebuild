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
	dev-db/mariadb
"
S="${WORKDIR}"

src_unpack(){
	mkdir -p "${S}"
}

src_install() {
	default
	dodir /usr/share/cloc3Elios_db/db_utils/sql
	insinto /usr/share/cloc3Elios_db/db_utils/sql
	doins -r "${FILESDIR}"/usr/share/cloc3Elios_db/db_utils/sql/*
}
