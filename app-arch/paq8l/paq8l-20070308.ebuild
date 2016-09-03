# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="Open source file compressor and archiver"
HOMEPAGE="http://www.cs.fit.edu/~mmahoney/compression"
SRC_URI="http://www.cs.fit.edu/~mmahoney/compression/${PN}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S=${WORKDIR}

src_compile() {
	$( tc-getCXX ) ${CXXFLAGS} -DNOASM -DUNIX ${PN}.cpp -o ${PN} || die "compile failed"
}

src_install() {
	dobin ${PN}
	dodoc readme.txt
}
