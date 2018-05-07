# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="Open source file compressor and archiver"
HOMEPAGE="http://mattmahoney.net/dc/"
SRC_URI="http://mattmahoney.net/dc/${PN}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
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
