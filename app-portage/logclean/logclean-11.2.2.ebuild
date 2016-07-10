# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Keep only (compressed) logs of installed packages and cleanup emerge.log"
HOMEPAGE="https://github.com/vaeth/logclean/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.12
	dev-perl/String-ShellQuote
	|| ( >=dev-lang/perl-5.14 virtual/perl-Term-ANSIColor )"
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- "${PN}" || die
	eapply_user
}

src_install() {
	dobin "${PN}"
	insinto /etc
	doins "${PN}.conf"
	insinto /usr/share/zsh/site-functions
	doins "_${PN}"
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
}
