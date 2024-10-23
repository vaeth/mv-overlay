# Copyright 2017-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A fast solver for the 0/1-knapsack problem with multiple knapsacks"
HOMEPAGE="https://github.com/vaeth/knapsack/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

DOCS=(knapsack.txt README.md ChangeLog)

RDEPEND="dev-libs/boost:="
DEPEND="${RDEPEND}"
