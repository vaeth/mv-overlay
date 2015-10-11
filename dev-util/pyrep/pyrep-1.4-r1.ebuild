# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"
PYTHON_COMPAT=( jython2_7 pypy{,3} python{2_7,3_{4,5}} )
inherit eutils python-single-r1

DESCRIPTION="Search and/or replace regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/pyrep/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}"

src_prepare() {
	python_fix_shebang "${S}"
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
		-- "${PN}" || die
	epatch_user
}

src_install() {
	dobin "${PN}"
	dodoc AUTHORS README
}
