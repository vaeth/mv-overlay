# Copyright 2012-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="A collection of POSIX shell scripts to invoke archiver programs"
HOMEPAGE="https://github.com/vaeth/archwrap/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
RDEPEND=">=app-shells/push-3 !<app-arch/brotli-1.0.4"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
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
