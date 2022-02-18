# Copyright 2013-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit optfeature

DESCRIPTION="find cruft files not managed by portage"
HOMEPAGE="https://github.com/vaeth/find_cruft/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.8"
#	|| ( >=dev-lang/perl-5.9.4 >=virtual/perl-File-Spec-3.0 )
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	default
}

src_install() {
	dobin bin/*
	dodoc README.md
	insinto /usr/lib/find_cruft
	doins -r etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
}
