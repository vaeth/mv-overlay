# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"
inherit eutils

DESCRIPTION="A frontend, beautifier, and path-fixer for diff -u"
HOMEPAGE="https://github.com/vaeth/diffhelp/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${PN}" || die
	epatch_user
}

src_install() {
	dobin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins "_${PN}"
}
