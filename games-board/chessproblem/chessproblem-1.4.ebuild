# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
WANT_LIBTOOL=none
AT_NOELIBTOOLIZE=yes
inherit autotools vcs-snapshot

DESCRIPTION="Find solutions of chess problems (mate, selfmate, and helpmate) with cooks"
HOMEPAGE="https://github.com/vaeth/chessproblem/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="debug optimization strong-optimization"

src_prepare() {
	if use prefix
	then	set --
	else	set -- -e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"'
	fi
	sed -e 's!\./chessproblem!chessproblem!' \
		"${@}" -- contrib/test.pl >test.pl || die
	eapply_user
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
	exeinto "/usr/share/doc/${PF}/"
	doexe test.pl
	docompress -x "/usr/share/doc/${PF}/test.pl"
}
