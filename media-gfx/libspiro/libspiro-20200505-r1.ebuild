# Copyright 1999-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A spline computation library"
HOMEPAGE="https://github.com/fontforge/libspiro"

SRC_URI="https://github.com/fontforge/libspiro/releases/download/20200505/${PN}-dist-${PV}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

LICENSE="GPL-3+"
SLOT="0"

IUSE=""
RESTRICT=""

src_install() {
	default
	find "${ED}" -type f '(' -name "*.la" -o -name "*.a" ')' -delete || die
}
