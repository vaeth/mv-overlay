# Copyright 2012-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"
RDEPEND="app-shells/push:0/1"
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
