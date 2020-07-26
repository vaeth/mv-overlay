# Copyright 2011-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Keep only (compressed) logs of installed packages and cleanup emerge.log"
HOMEPAGE="https://github.com/vaeth/logclean/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
