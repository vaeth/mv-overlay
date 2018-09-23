# Copyright 2012-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

mPN="${PN%-*}"
DESCRIPTION="Organize your world file and find installed packages or differences to @world"
HOMEPAGE="https://github.com/vaeth/world/"
SRC_URI="https://github.com/vaeth/${mPN}/archive/v${PV}.tar.gz -> ${mPN}-${PV}.tar.gz"
S="${WORKDIR}/${mPN}-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}/${mPN}-${PV}"

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s'\${EPREFIX}'\\'${EPREFIX}\\''" \
			-- bin/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- bin/* || die
	fi
	default
}

src_install() {
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
