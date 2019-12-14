# Copyright 2011-2019 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="wrapper for sudo which can pass X authority data and deal with screen and tmux"
HOMEPAGE="https://github.com/vaeth/sudox/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
	dodoc README.md ChangeLog
	newdoc sudoers.d/${PN} sudoers.d
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
