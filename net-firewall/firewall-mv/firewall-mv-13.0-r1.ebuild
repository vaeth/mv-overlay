# Copyright 2012-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Initialize iptables and net-related sysctl variables"
HOMEPAGE="https://github.com/vaeth/firewall-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=">=app-shells/push-2.0-r2"
DEPEND=""

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s!/etc/!${EPREFIX}/etc/!g" \
			-e "s!/usr/!${EPREFIX}/usr/!g" \
			-- sbin/* etc/* systemd/* || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- sbin/* || die
	fi
	default
}

src_compile() {
	emake "SYSTEMUNITDIR=$(systemd_get_systemunitdir)"
}

src_install() {
	dodoc README
	emake DESTDIR="${ED}" "SYSTEMUNITDIR=$(systemd_get_systemunitdir)" install
}
