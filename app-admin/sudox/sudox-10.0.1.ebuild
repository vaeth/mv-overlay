# Copyright 2011-2023 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="wrapper for sudo which can pass X authority data and deal with screen and tmux"
HOMEPAGE="https://github.com/vaeth/sudox/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"
RDEPEND="app-admin/sudo
	app-shells/push:0/1"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)"'/bin/sh"' \
		-- bin/* || die
	default
}

src_install() {
	dodoc README.md ChangeLog
	newdoc sudoers.d/${PN} sudoers.d
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	insinto /usr/share/wayland-sessions
	doins usr/share/wayland-sessions/*
}
