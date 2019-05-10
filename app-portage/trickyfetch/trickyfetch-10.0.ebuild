# Copyright 2012-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Plugin for FETCHCOMMAND to help organize and cleanup your DISTDIR"
HOMEPAGE="https://github.com/vaeth/trickyfetch/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s'\\(PATH=.\\)/etc'\\1${EPREFIX}/etc'" \
			-- "${S}/bin/trickyfetch" || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			 -- "${S}"/bin/* || die
	fi
	default
}

src_install() {
	dobin bin/*
	insinto /etc
	doins etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
	dodoc README.md THANKS
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS:-0.}" in
	' '[0-7].*)
		elog "Please adapt /etc/trickyfetch.conf to your needs";;
	esac
	optfeature "faster execution" '>=app-portage/eix-0.32.2'
}
