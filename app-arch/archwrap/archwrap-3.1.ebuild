# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="A collection of POSIX shell scripts to invoke archiver programs"
HOMEPAGE="https://github.com/vaeth/archwrap/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=">=app-shells/push-2.0-r2"
DEPEND=""

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-e 's"^\. archwrap\.sh$". '"${EPREFIX}/usr/lib/archwrap/archwrap.sh"'"' \
			-- "${i}" || die
	done
	eapply_user
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}"
		then	doins "${i}"
		elif [ "${i#*/}" != 'archwrap.sh' ]
		then	dobin "${i}"
		fi
	done
	insinto /usr/lib/archwrap
	doins bin/archwrap.sh
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README archwrap_alias
}
