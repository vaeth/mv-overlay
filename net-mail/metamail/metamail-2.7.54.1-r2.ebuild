# Copyright 1999-2025 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic toolchain-funcs

RESTRICT="mirror"

MY_PV=$(ver_cut 1-2)
DEB_PV=${MY_PV}-$(ver_cut 3)

DESCRIPTION="Metamail (with Debian patches) - Generic MIME package"
HOMEPAGE="http://ftp.funet.fi/pub/unix/mail/metamail/"
SRC_URI="http://ftp.funet.fi/pub/unix/mail/metamail/mm${MY_PV}.tar.Z
	mirror://debian/pool/main/m/metamail/metamail_${DEB_PV}.diff.gz"
#	https://sibelius.debian.org/debian/pool/main/m/metamail/metamail_${DEB_PV}.diff.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~hppa ppc ppc64 ~s390 sparc x86"
IUSE="static-libs"

DEPEND="sys-libs/ncurses:=
	app-arch/sharutils
	net-mail/mailbase"
RDEPEND="
	${DEPEND}
	app-misc/mime-types
	sys-apps/debianutils
	!app-misc/run-mailcap"
BDEPEND="virtual/pkgconfig"

S=${WORKDIR}/mm${MY_PV}/src

src_prepare() {
	# Hackish workaround to make the legacy code work with >=gcc-15.
	# A cleaner approach would be to add/fix function declarations, but this
	# should better happen upstream
	append-cflags -std=gnu17 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-return-mismatch

	eapply "${WORKDIR}"/metamail_${DEB_PV}.diff
	eapply "${FILESDIR}"/${PN}-2.7.45.3-CVE-2006-0709.patch
	eapply "${FILESDIR}"/${PN}-2.7.53.3-glibc-2.10.patch

	# respect CFLAGS
	sed -i -e 's/CFLAGS/LIBS/' \
		"${S}"/src/{metamail,richmail}/Makefile.am || die

	# add missing include - QA
	sed -i -e '/config.h/a #include <string.h>' \
		"${S}"/src/metamail/shared.c || die

	# Fix building with ncurses[tinfo]
	sed -i -e "s/-lncurses/$($(tc-getPKG_CONFIG) --libs ncurses)/" \
		src/richmail/Makefile.am \
		src/metamail/Makefile.am || die

	eapply_user
	eautoreconf
	chmod +x "${S}"/configure
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc CREDITS README
	rm man/mmencode.1
	rm man/mailcap.5
	doman man/* debian/mimencode.1 debian/mimeit.1

	use static-libs || find "${D}"/usr/lib* -name '*.la' -delete
}
