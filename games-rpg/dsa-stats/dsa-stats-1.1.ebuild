# Copyright 2016-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="calculate stat probabalities for the role playing game DSA - Das schwarze Auge"
HOMEPAGE="https://github.com/vaeth/dsa-stats/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

src_install() {
	dodoc README.md
	dobin dsa
}
