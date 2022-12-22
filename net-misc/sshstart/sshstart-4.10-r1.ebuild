# Copyright 2012-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Start ssh-agent/ssh-add only if you really use ssh or friends"
HOMEPAGE="https://github.com/vaeth/sshstart/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="split-usr"
RDEPEND="app-shells/push:0/1"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}$(usex split-usr '' /usr)/bin/sh"'"' \
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
