# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

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
		-- bin/* || die
	eapply_user
}

src_install() {
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
