# Copyright 2016-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="Some personal wrappers for the most important git commands"
HOMEPAGE="https://github.com/vaeth/git-wrappers-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-4.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}"'/bin/sh"' \
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
