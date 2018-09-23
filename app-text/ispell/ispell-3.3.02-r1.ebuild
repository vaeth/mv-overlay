# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

PATCH_VER="0.3"

DESCRIPTION="fast screen-oriented spelling checker"
HOMEPAGE="https://fmg-www.cs.ucla.edu/geoff/ispell.html"
SRC_URI="https://fmg-www.cs.ucla.edu/geoff/tars/${P}.tar.gz
		mirror://gentoo/${P}-gentoo-${PATCH_VER}.diff.bz2"

LICENSE="HPND"
SLOT="0/3.3.02"
KEYWORDS="alpha amd64 ~arm hppa ~mips ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="
	sys-apps/miscfiles
	sys-libs/ncurses:0=
"
DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/${P}-glibc-2.10.patch
	eapply -p0 "${WORKDIR}"/${P}-gentoo-${PATCH_VER}.diff
	sed -e "s:GENTOO_LIBDIR:$(get_libdir):" -i local.h || die
	sed -e "s:\(^#define CC\).*:\1 \"$(tc-getCC)\":" -i local.h || die
	sed -e "s:\(^#define CFLAGS\).*:\1 \"${CFLAGS}\":" -i config.X || die
	default
}

src_configure() {
	# Prepare config.sh for installation phase to avoid twice rebuild
	emake -j1 config.sh
	sed \
		-e "s:^\(BINDIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(LIBDIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(MAN1DIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(MAN45DIR='\)\(.*\):\1${ED}\2:" \
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
