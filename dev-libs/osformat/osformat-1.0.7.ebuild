# Copyright 2017-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

SRC_URI="https://github.com/vaeth/osformat/releases/download/v${PV}/${P}.tar.xz"

DESCRIPTION="C++ library for a typesafe printf/sprintf based on << conversion"
HOMEPAGE="https://github.com/vaeth/osformat/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE=""

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
