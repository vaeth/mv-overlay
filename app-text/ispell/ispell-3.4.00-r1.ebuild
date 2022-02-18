# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit toolchain-funcs

DESCRIPTION="fast screen-oriented spelling checker"
HOMEPAGE="http://fmg-www.cs.ucla.edu/geoff/ispell.html"
SRC_URI="http://fmg-www.cs.ucla.edu/geoff/tars/${P}.tar.gz"

LICENSE="HPND"
SLOT="0/3.4.00"
KEYWORDS="~alpha amd64 ~arm hppa ~mips ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="+tinfo"

RDEPEND="
	sys-apps/miscfiles
	sys-libs/ncurses:0=[tinfo=]
"
DEPEND="${RDEPEND}"

src_prepare() {
	local tinfo
	if use tinfo ; then
		tinfo='s:\(^#define TERMLIB\).*:\1 "-ltinfo":'
	else
		tinfo=
	fi
	sed -i \
		-e 's:\(^#define CC\).*:\1 "'"$(tc-getCC)"'":' \
		-e 's:\(^#define CFLAGS\).*:\1 "'"${CFLAGS}"'":' \
		${tinfo:+-e "${tinfo}"} \
		-- "${S}"/config.X || die
	sed -i \
		-e 's:/usr/local/man:'"${EPREFIX}"'/usr/share/man:' \
		-e 's:/usr/local/lib:'"${EPREFIX}"'/usr/'"$(get_libdir)/${PN}:" \
		-e 's:/usr/local:'"${EPREFIX}"'/usr:' \
		-- "${S}"/local.h.* || die
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
