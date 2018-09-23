# Copyright 2017-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
WANT_LIBTOOL=none
AT_NOELIBTOOLIZE=yes
inherit autotools

DESCRIPTION="Find solutions of chess problems (mate, selfmate, and helpmate) with cooks"
HOMEPAGE="https://github.com/vaeth/chessproblem/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="debug +multithreading optimization propagate-signal strong-optimization unlimited"

DEPEND="dev-libs/osformat"
RDEPEND=$DEPEND

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- contrib/test.pl || die
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_with multithreading) \
		$(use_enable propagate-signal) \
		$(use_enable unlimited) \
		$(use_enable debug debugging) \
		$(use_enable optimization) \
		$(use_enable strong-optimization)
}

src_install() {
	default
	exeinto "/usr/share/doc/${PF}/"
	doexe contrib/test.pl
	docompress -x "/usr/share/doc/${PF}/test.pl"
}
