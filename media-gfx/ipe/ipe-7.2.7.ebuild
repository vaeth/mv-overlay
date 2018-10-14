# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit desktop flag-o-matic toolchain-funcs

DESCRIPTION="Drawing editor for creating figures in PDF or PS formats"
HOMEPAGE="http://ipe.otfried.org/"
SRC_URI="https://dl.bintray.com/otfried/generic/ipe/7.2/${P}-src.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="
	app-text/texlive-core
	>=dev-lang/lua-5.3:=
	media-fonts/urw-fonts
	media-libs/freetype:2
	x11-libs/cairo
	dev-qt/qtcore:5
	dev-qt/qtgui:5"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${P}/src"

PATCHES=("${FILESDIR}"/xlocale.patch)

src_prepare() {
	filter-flags -fPIE -pie '-flto*' -fwhole-program +D_GLIBCXX_ASSERTIONS
	sed -i \
		-e 's/fpic/fPIC/' \
		-e "s'\$(IPEPREFIX)/lib'\$(IPEPREFIX)/$(get_libdir)'g" \
		-e "s'\(LUA_CFLAGS.*=\).*'\1 -I${EROOT}/usr/include/lua5.3'" \
		-e 's/\(LUA_LIBS.*=\).*/\1 -llua5.3/' \
		config.mak || die
	sed -i -e 's/install -s/install/' common.mak || die
	default
}

src_compile() {
	emake \
		CXX=$(tc-getCXX) \
		IPEPREFIX="${EPREFIX}/usr" \
		IPEDOCDIR="${EPREFIX}/usr/share/doc/${PF}/html"
}

src_install() {
	emake install \
		IPEPREFIX="${EPREFIX}/usr" \
		IPEDOCDIR="${EPREFIX}/usr/share/doc/${PF}/html" \
		INSTALL_ROOT="${ED}"
	dodoc ../{news,readme}.txt
	doicon ipe/icons/ipe.png
	make_desktop_entry ipe Ipe ipe
}
