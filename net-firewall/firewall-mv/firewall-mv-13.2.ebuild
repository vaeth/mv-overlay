# Copyright 2012-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="split-usr"
RDEPEND=">=app-shells/push-2.0-r2"
DEPEND=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s!/etc/!${EPREFIX}/etc/!g" \
			-e "s!/usr/!${EPREFIX}/usr/!g" \
			-- sbin/* etc/* systemd/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(get_usr)/bin/sh"'"' \
			-- sbin/* || die
	fi
	default
}

src_compile() {
	emake "SYSTEMUNITDIR=$(systemd_get_systemunitdir)" BINDIR="$(get_usr)/sbin" LIBDIR="$(get_usr)/lib/firewall"
}

src_install() {
	dodoc README.md
	emake DESTDIR="${ED}" "SYSTEMUNITDIR=$(systemd_get_systemunitdir)" BINDIR="$(get_usr)/sbin" LIBDIR="$(get_usr)/lib/firewall" install
}

get_usr() {
		use split-usr || echo /usr
}
