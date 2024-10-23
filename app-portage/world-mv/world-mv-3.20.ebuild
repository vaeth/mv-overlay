# Copyright 2012-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

mPN="${PN%-*}"
DESCRIPTION="Organize your world file and find installed packages or differences to @world"
HOMEPAGE="https://github.com/vaeth/world/"
SRC_URI="https://github.com/vaeth/${mPN}/archive/v${PV}.tar.gz -> ${mPN}-${PV}.tar.gz"
S="${WORKDIR}/${mPN}-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"
S="${WORKDIR}/${mPN}-${PV}"

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s'\${EPREFIX}'\\'${EPREFIX}\\''" \
			-- bin/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)/bin/sh"'"' \
			-- bin/* || die
	fi
	default
}

src_install() {
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
