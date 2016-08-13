# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( pypy python2_7 python3_3 python3_4 python3_5 )

case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/proteusx/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	RESTRICT="mirror"
	SRC_URI="https://github.com/proteusx/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
esac
inherit python-single-r1

DESCRIPTION="Updated version of an old Portage information extractor"
HOMEPAGE="https://github.com/proteusx/etcat/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="app-portage/gentoolkit[${PYTHON_USEDEP}]"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	python_fix_shebang "${S}"
	eapply_user
}

src_install() {
	dobin "${PN}"
}
