# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit eutils

DESCRIPTION="A collection of perl scripts (replacement in files, syncing dirs etc)"
HOMEPAGE="https://github.com/vaeth/mv_perl/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.12"
#	|| ( >=dev-lang/perl-5.9.4 >=virtual/perl-File-Spec-3.0 )
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )
#	|| ( >=dev-lang/perl-5.7.3 virtual/perl-Digest-MD5 )
#	|| ( >=dev-lang/perl-5.7.3 virtual/perl-Time-HiRes )

src_install() {
	dobin bin/*
	dodoc README
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}

pkg_postinst() {
	optfeature "support to set timestamps of symlinks" 'dev-perl/File-lchown'
}
