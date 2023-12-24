# Copyright 2012-2023 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A collection of POSIX shell scripts to invoke archiver programs"
HOMEPAGE="https://github.com/vaeth/archwrap/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"
RDEPEND="app-shells/push:0/1"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)/bin/sh"'"' \
			-e 's"^\. archwrap\.sh$". '"${EPREFIX}/usr/lib/archwrap/archwrap.sh"'"' \
			-- "${i}" || die
	done
	default
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}"
		then	doins "${i}"
		elif [ "${i#*/}" != 'archwrap.sh' ]
		then	dobin "${i}"
		fi
	done
	insinto /usr/lib/archwrap
	doins bin/archwrap.sh
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README.md archwrap_alias
}
