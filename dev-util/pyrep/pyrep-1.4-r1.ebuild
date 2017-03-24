# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
PYTHON_COMPAT=( pypy{,3} python{2_7,3_{4,5,6}} )
inherit python-any-r1

DESCRIPTION="Search and/or replace regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/pyrep/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="${PYTHON_DEPS}"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
		-- "${PN}" || die
	eapply_user
}

src_install() {
	dobin "${PN}"
	dodoc AUTHORS README
}
