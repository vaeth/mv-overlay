# Copyright 2017-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
WANT_LIBTOOL=none
AT_NOELIBTOOLIZE=yes
inherit autotools

DESCRIPTION="Find solutions of chess problems (mate, selfmate, and helpmate) with cooks"
HOMEPAGE="https://github.com/vaeth/chessproblem/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="nothreads"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="debug optimization strong-optimization"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- contrib/test.pl || die
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug debugging) \
		$(use_enable optimization) \
		$(use_enable strong-optimization)
}

src_install() {
	default
	mv -- "${ED}/usr/bin/chessproblem"{,-nothreads}
	exeinto "/usr/share/doc/${PF}/"
	doexe contrib/test.pl
	docompress -x "/usr/share/doc/${PF}/test.pl"
}
