# Copyright 1999-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for command-line recorders cdrtools and cdrkit"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x86-solaris"
HOMEPAGE=
SRC_URI=
LICENSE=
IUSE=

RDEPEND="|| ( app-shells/schily-tools[schilytools_cdrtools] app-cdr/cdrtools )"
