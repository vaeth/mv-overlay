# Copyright 2011-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="wrapper for sudo which can pass X authority data and deal with screen and tmux"
HOMEPAGE="https://github.com/vaeth/sudox/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="app-admin/sudo
	>=app-shells/push-2.0-r2"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}"'/bin/sh"' \
		-- bin/* || die
	default
}

src_install() {
	dodoc README ChangeLog
	newdoc sudoers.d/${PN} sudoers.d
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
