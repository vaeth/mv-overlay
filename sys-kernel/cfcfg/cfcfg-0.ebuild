# Copyright 2023 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Yet another Linux kernel configuration comparator"
HOMEPAGE="https://sourceforge.net/projects/cfcfg/"
SRC_URI="mirror://sourceforge/project/cfcfg/${PN}.tgz -> ${P}.tar.gz"
S="${WORKDIR}/cfcfg.git"

LICENSE="GPL-3+"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
SLOT="0"
IUSE=""

src_prepare() {
	mv cfcfg.1.man cfcfg.1
	default
}

src_install() {
	dobin cfcfg
	doman cfcfg.1
	dodoc README.md
}
