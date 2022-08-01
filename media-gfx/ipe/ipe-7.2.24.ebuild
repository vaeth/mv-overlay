# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

LUA_COMPAT=( lua5-{3..4} )

inherit desktop flag-o-matic lua-single toolchain-funcs

DESCRIPTION="Drawing editor for creating figures in PDF or PS formats"
HOMEPAGE="http://ipe.otfried.org/"
SRC_URI="https://github.com/otfried/ipe/releases/download/v${PV}/${PN}-${PV}-src.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

REQUIRED_USE="${LUA_REQUIRED_USE}"

DEPEND="${LUA_DEPS}
	media-fonts/urw-fonts
	media-gfx/libspiro
	media-libs/freetype:2
	media-libs/libjpeg-turbo
	media-libs/libpng
	sci-libs/gsl:=
	sys-libs/zlib
	x11-libs/cairo
	dev-qt/qtcore:5
	dev-qt/qtgui:5"
RDEPEND="${DEPEND}
	|| ( app-text/texlive-core net-misc/curl )"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${P}/src"

src_prepare() {
	filter-flags -fPIE -pie '-flto*' -fwhole-program -Wl,--no-undefined \
		-DNDEBUG -D_GLIBCXX_ASSERTIONS
	sed -i \
		-e 's/fpic/fPIC/' \
		-e "s'\$(IPEPREFIX)/lib'\$(IPEPREFIX)/$(get_libdir)'g" \
		-e "s'\(LUA_CFLAGS.*=\).*'\1 $(lua_get_CFLAGS)'" \
		-e "s'\(LUA_LIBS.*=\).*'\1 $(lua_get_LIBS)'" \
		-e "s'\(MOC.*=\).*'\1 ${EPREFIX}/usr/$(get_libdir)/qt5/bin/moc'" \
		config.mak || die
	sed -i \
		-e 's!-std=c++1.!!' \
		-e 's/install -s/install/' \
		-e "s'\$(CXX)'\$(CXX) -I${S}/ipecanvas -I${S}/ipecairo -I${S}/include'" \
		common.mak || die
	default
}

src_compile() {
	PATH=${EPREFIX}/$(get_libdir)/qt5/bin${PATH:+:}${PATH-}
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
	make_desktop_entry ipe Ipe ipe
}
