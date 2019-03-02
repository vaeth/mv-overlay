# Copyright 2014-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DIST_AUTHOR=PEVANS
DIST_VERSION=0.02
inherit perl-module

DESCRIPTION="Use the lchown(2) and lutimes(2) system call from Perl"

SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}
	dev-perl/ExtUtils-CChecker
	dev-perl/Module-Build"
