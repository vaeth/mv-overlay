# Copyright 2016-2025 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="compare files or directories, including metadata"
HOMEPAGE="https://github.com/vaeth/comp/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~m68k ~mips ppc ppc64 ~s390 x86"
IUSE=""

# This should really depend on a USE-flag but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND="dev-perl/String-ShellQuote"

RDEPEND=">=dev-lang/perl-5.8
${OPTIONAL_RDEPEND}"
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
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
