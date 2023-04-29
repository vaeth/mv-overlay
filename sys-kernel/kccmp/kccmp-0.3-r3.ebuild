# Copyright 1999-2023 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit qmake-utils
RESTRICT="mirror"

DESCRIPTION="A simple tool for comparing two linux kernel .config files"
HOMEPAGE="https://github.com/jeff-dagenais/kccmp"
EGIT_COMMIT="ce42ebaf3fb09c4cff009e6ed7ff8afa683b2eec"
SRC_URI="https://github.com/jeff-dagenais/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

DEPEND="dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
RDEPEND="${DEPEND}"

src_prepare() {
	echo "QT += widgets" >> ${PN}.pro
	default
}

src_configure() {
	eqmake5 "${S}"/kccmp.pro
}

src_install() {
	dobin kccmp
	dodoc README
}
