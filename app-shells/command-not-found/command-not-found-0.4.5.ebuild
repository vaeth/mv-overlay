# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"
inherit cmake-utils eutils flag-o-matic multilib

DESCRIPTION="If a command is not found (bash/zsh), search ARCH database for packages with similar commands"
HOMEPAGE="https://github.com/metti/command-not-found/"
SRC_URI="https://github.com/metti/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON="sys-libs/tdb"
DEPEND="${COMMON}"
RDEPEND="${COMMON}"

S="${WORKDIR}/${P}/src"

src_prepare() {
	PREFIX=${EPREFIX}
	filter-flags -fwhole-program
	sed -i -e 1d -e '2i#! /bin/sh' cnf-cron.in || die
	sed -i \
		-e "s!usr/lib!usr/$(get_libdir)!g" \
		-e "/^INSTALL.*cnf\.sh/,/^INSTALL/{/EXECUTE/d}" \
		CMakeLists.txt || die
	sed -i -e "s/function[[:space:]]*\([^[:space:](]*\)[[:space:]]*(/\1(/" \
		cnf.sh || die
	epatch_user
}

src_install() {
	dodir /var/lib/cnf
	cmake-utils_src_install
}

pkg_postrm() {
	local a
	if [ -z "${REPLACED_BY_VERSION}" ] && a="${EPREFIX}/var/lib/cnf" && \
		test -d "${a}"
	then	ewarn "removing now unneeded ${a}"
		rm -rf -- "${a}"
	fi
}
