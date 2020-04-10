# Copyright 2012-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="Start ssh-agent/ssh-add only if you really use ssh or friends"
HOMEPAGE="https://github.com/vaeth/sshstart/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
RDEPEND=">=app-shells/push-2.0-r2
	!<dev-vcs/git-wrappers-2.0"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${i}" || die
	done
	default
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}"
		then	doins "${i}"
		else	dobin "${i}"
		fi
	done
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README.md
}
