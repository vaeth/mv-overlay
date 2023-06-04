# Copyright 2016-2023 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/proteusx/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	RESTRICT="mirror"
	SRC_URI="https://github.com/proteusx/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
esac
inherit python-single-r1

DESCRIPTION="Updated version of an old Portage information extractor"
HOMEPAGE="https://github.com/proteusx/etcat/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep 'app-portage/gentoolkit[${PYTHON_USEDEP}]')"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	python_fix_shebang "${S}"
	default
}

src_install() {
	dobin "${PN}"
}
