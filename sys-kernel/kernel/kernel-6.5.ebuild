# Copyright 2011-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit optfeature

DESCRIPTION="A POSIX shell script to compile the kernel with user permissions"
HOMEPAGE="https://github.com/vaeth/kernel/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"

# This should really depend on a USE-flag but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND=">=app-shells/runtitle-2.3"

RDEPEND="app-admin/sudo
	app-admin/sudox
	app-shells/push:0/1
	!<dev-util/ccache-3.2
	${OPTIONAL_RDEPEND}"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)/bin/sh"'"' \
		-- bin/* || die
	default
}

src_install() {
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}

pkg_postinst() {
	optfeature "faster execution" '>=app-portage/eix-0.32.2'
}
