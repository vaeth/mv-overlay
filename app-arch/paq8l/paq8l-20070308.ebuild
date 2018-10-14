# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="Open source file compressor and archiver"
HOMEPAGE="http://mattmahoney.net/dc/"
SRC_URI="http://mattmahoney.net/dc/${PN}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
