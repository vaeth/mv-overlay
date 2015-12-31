# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"

DIST_AUTHOR=PEVANS
DIST_VERSION=0.02
inherit perl-module

DESCRIPTION="Use the lchown(2) and lutimes(2) system call from Perl"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}
	dev-perl/ExtUtils-CChecker
	dev-perl/Module-Build"
