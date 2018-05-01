# Copyright 2012-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="Search and/or replace regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/pyrep/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/python"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
		-- bin/* || die
	default
}

src_install() {
	dobin bin/*
	dodoc AUTHORS README.md
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
