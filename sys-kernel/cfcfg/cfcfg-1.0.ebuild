# Copyright 2023-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Yet another Linux kernel configuration comparator"
HOMEPAGE="https://sourceforge.net/projects/cfcfg/"
SRC_URI="https://sourceforge.net/projects/cfcfg/files/${P}.tgz -> ${P}.tar"
S="${WORKDIR}/cfcfg.git"

LICENSE="GPL-3+"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
SLOT="0"
IUSE=""

src_prepare() {
	mv cfcfg.1.man cfcfg.1
	mv cfgsymbols.1.man cfgsymbols.1
	default
}

src_install() {
	dobin cfcfg cfgsymbols cfgsymbols.awk
	doman cfcfg.1 cfgsymbols.1
	dodoc README.md cfgsymbols.1.md cfcfg.1.md
}
