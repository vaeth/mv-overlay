# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="fast screen-oriented spelling checker"
HOMEPAGE="http://fmg-www.cs.ucla.edu/geoff/ispell.html"
SRC_URI="http://fmg-www.cs.ucla.edu/geoff/tars/${P}.tar.gz"

LICENSE="HPND"
SLOT="0/3.4.00"
KEYWORDS="alpha amd64 ~arm hppa ~mips ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="
	sys-apps/miscfiles
	sys-libs/ncurses:0=
"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i \
		-e 's:/usr/local/man:'"${EPREFIX}"'/usr/share/man:' \
		-e 's:/usr/local/lib:'"${EPREFIX}"'/usr/'"$(get_libdir)/${PN}:" \
		-e 's:/usr/local:'"${EPREFIX}"'/usr:' \
		-- "${S}"/local.h.* || die
	sed -i \
		-e 's:\(^#define CC\).*:\1 "'"$(tc-getCC)"'":' \
		-e 's:\(^#define CFLAGS\).*:\1 "'"${CFLAGS}"'":' \
		-- "${S}"/config.X || die
	default
}

src_configure() {
	# Prepare config.sh for installation phase to avoid twice rebuild
	emake -j1 config.sh
	sed \
		-e "s:^\(BINDIR='\)${EPREFIX}\(/usr.*\):\1${ED}\2:" \
		-e "s:^\(LIBDIR='\)${EPREFIX}\(/usr.*\):\1${ED}\2:" \
		-e "s:^\(MAN1DIR='\)${EPREFIX}\(/usr.*\):\1${ED}\2:" \
		-e "s:^\(MAN45DIR='\)${EPREFIX}\(/usr.*\):\1${ED}\2:" \
			< config.sh > config.sh.install
}

src_compile() {
	emake -j1
}

src_install() {
	mv config.sh.install config.sh
	emake -j1 install
	dodoc CHANGES Contributors README WISHES
}
