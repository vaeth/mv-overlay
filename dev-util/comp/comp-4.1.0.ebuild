# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit eutils

DESCRIPTION="compare files or directories, including metadata"
HOMEPAGE="https://github.com/vaeth/comp/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!<dev-util/mv_perl-3
>=dev-lang/perl-5.12"
#	|| ( >=dev-lang/perl-5.9.4 >=virtual/perl-File-Spec-3.0 )
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	eapply_user
}

src_install() {
	dobin bin/*
	dodoc README
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}

pkg_postinst() {
	optfeature "improved output" 'dev-perl/String-ShellQuote'
}
