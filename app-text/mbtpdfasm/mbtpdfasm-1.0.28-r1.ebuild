# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

MY_P="mbtPdfAsm-${PV}"

DESCRIPTION="Tool to assemble/merge, extract information from, and update the metadata in PDF"
HOMEPAGE="http://thierry.schmit.free.fr/dev/mbtPdfAsm/mbtPdfAsm2.html"
SRC_URI="http://thierry.schmit.free.fr/spip/IMG/gz/${MY_P}.tar.gz
	http://sbriesen.de/gentoo/distfiles/${P}-manual.pdf.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

S="${WORKDIR}"

# https://bugs.gentoo.org/show_bug.cgi?id=594668
patch_to_standard() {
	local i j b
	b='[^_abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKMNOPQRSTUVWXYZ0123456789]'
	for i
	do	j=$i
		while ! case $j in
		*__*)
			false;;
		esac
		do	j=${j%%__*}_m_${j#*__}
		done
		case $i in
		_[ABCDEFGHIJKLMNOPQRSTUVWXYZ]*)
			j=_m$i;;
		esac
		[ "$j" != "$i" ] || die
		einfo "Renaming $i -> $j"
		sed -i \
			-e "s/^$i\$/$j/g" \
			-e "s/^$i\($b\)/$j\1/g" \
			-e "s/\($b\)$i\($b\)/\1$j\2/g" \
			-- *.c* *.h* || die
	done
}

src_prepare() {
	eapply -p0 \
		"${FILESDIR}/${P}-makefile.diff" \
		"${FILESDIR}/${P}-64bit.diff" \
		"${FILESDIR}/${P}-main.diff"

	# use system zlib
	eapply "${FILESDIR}/${P}-zlib.diff"
	mv "zlib.h" "zlib.h.disabled" || die

	patch_to_standard $(sed -n -e 's/^[[:space:]]*\#define[[:space:]]*\(_[ABCDEFGHIJKLMNOPQRSTUVWXYZ][^[:space:]]*\|[^[:space:]]*__[^[:space:]]*\).*/\1/p' \
		-- *.c* *.h*)
	default
}

src_compile() {
	emake CC="$(tc-getCXX)" || die "emake failed"
}

src_install() {
	dobin mbtPdfAsm || die "install failed"
	insinto "/usr/share/doc/${PF}"
	newins ${P}-manual.pdf mbtPdfAsm.pdf
}
