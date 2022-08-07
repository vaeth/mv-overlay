# Copyright 1999-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A spline computation library"
HOMEPAGE="https://github.com/fontforge/libspiro"

SRC_URI="https://github.com/fontforge/libspiro/releases/download/${PV}/${PN}-dist-${PV}.tar.gz"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"

LICENSE="GPL-3+"
SLOT="0"

IUSE=""
RESTRICT=""

src_install() {
	default
	find "${ED}" -type f '(' -name "*.la" -o -name "*.a" ')' -delete || die
}
