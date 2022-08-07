# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="Open source file compressor and archiver"
HOMEPAGE="http://mattmahoney.net/dc/"
SRC_URI="http://mattmahoney.net/dc/${PN}.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

BDEPEND="app-arch/unzip"
RDEPEND=""

S=${WORKDIR}

src_compile() {
	$( tc-getCXX ) ${CXXFLAGS} -DNOASM -DUNIX ${PN}.cpp -o ${PN} || die "compile failed"
}

src_install() {
	dobin ${PN}
	dodoc readme.txt
}
