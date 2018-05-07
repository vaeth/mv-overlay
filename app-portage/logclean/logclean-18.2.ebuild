# Copyright 2011-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Keep only (compressed) logs of installed packages and cleanup emerge.log"
HOMEPAGE="https://github.com/vaeth/logclean/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# This should really depend on a USE-flag but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND="dev-perl/File-Which"

RDEPEND=">=dev-lang/perl-5.8
	dev-perl/String-ShellQuote
	|| ( >=dev-lang/perl-5.14 virtual/perl-Term-ANSIColor )
	${OPTIONAL_RDEPEND}"
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	default
}

src_install() {
	dodoc README.md
	dobin bin/*
	insinto /etc
	doins etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}

pkg_postinst() {
	optfeature "faster execution" 'app-portage/eix'
}
