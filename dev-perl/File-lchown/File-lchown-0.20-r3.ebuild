# Copyright 2014-2024 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DIST_AUTHOR=PEVANS
DIST_VERSION=0.02
inherit perl-module

DESCRIPTION="Use the lchown(2) and lutimes(2) system call from Perl"

SLOT="0"
KEYWORDS="~amd64 ~m68k ~mips ~s390 ~x86"
IUSE=""

PATCHES=(
	"${FILESDIR}"/${P}-fix-include.patch
)
RDEPEND="virtual/perl-XSLoader"
BDEPEND="${RDEPEND}
	dev-perl/Module-Build
	dev-perl/ExtUtils-CChecker"
