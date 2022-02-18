# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit qmake-utils

DESCRIPTION="A simple tool for comparing two linux kernel .config files"
HOMEPAGE="http://stoopidsimple.com/kccmp/"
SRC_URI="http://stoopidsimple.com/files/${P}.tar.gz"

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
