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
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
