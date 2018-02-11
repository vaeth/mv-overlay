# Copyright 2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="A collection of perl scripts (replacement in files, syncing dirs etc)"
HOMEPAGE="https://github.com/vaeth/mv_perl/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# These should really depend on USE-flags but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND="dev-perl/File-lchown
dev-perl/String-Escape
dev-perl/String-ShellQuote"

RDEPEND=">=dev-lang/perl-5.8
	|| ( >=dev-lang/perl-5.9.4 >=virtual/perl-File-Spec-3.0 )
	${OPTIONAL_RDEPEND}"
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )
#	|| ( >=dev-lang/perl-5.7.3 virtual/perl-Digest-MD5 )
#	|| ( >=dev-lang/perl-5.7.3 virtual/perl-Time-HiRes )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	eapply_user
}

src_install() {
	dobin bin/*
	dodoc README.md
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
