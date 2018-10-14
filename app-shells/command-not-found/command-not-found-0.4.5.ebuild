# Copyright 2012-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit cmake-utils flag-o-matic multilib

DESCRIPTION="search ARCH database for packages with similar commands"
HOMEPAGE="https://github.com/metti/command-not-found/"
SRC_URI="https://github.com/metti/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
	default
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
