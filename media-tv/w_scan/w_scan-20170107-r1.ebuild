# Copyright 1999-2024 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
DESCRIPTION="Scan DVB-C/DVB-T/DVB-S channels"
HOMEPAGE="http://wirbel.htpc-forum.de/w_scan/index2.html"
SRC_URI="http://wirbel.htpc-forum.de/w_scan/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="doc examples +plp-id-zero"

DEPEND="sys-kernel/linux-headers"
RDEPEND=""

src_prepare() {
	use plp-id-zero && eapply "${FILESDIR}"/plp_id.patch
	default
}

src_install() {
	emake DESTDIR="${ED}" install

	dodoc ChangeLog README

	if use doc; then
		dodoc doc/README.file_formats doc/README_VLC_DVB
	fi

	if use examples; then
		docinto examples
		dodoc doc/rotor.conf
	fi
}
