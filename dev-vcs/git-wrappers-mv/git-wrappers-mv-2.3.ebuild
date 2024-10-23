# Copyright 2016-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Some personal wrappers for the most important git commands"
HOMEPAGE="https://github.com/vaeth/git-wrappers-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-4.0"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="split-usr"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)"'/bin/sh"' \
		-- bin/git-[b-z]* || die
	default
}

src_install() {
	local i
	for i in bin/*
	do	test -h "$i" || dobin "$i"
	done
	dosym git-tag /usr/bin/git-archive
	dosym git-commit /usr/bin/git-status
	dosym git-commit /usr/bin/git-update-index
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README
}
