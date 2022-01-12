# Copyright 2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit user

KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT=0
DESCRIPTION="Group for sys-apps/schedule"
HOMEPAGE=
SRC_URI=
LICENSE=
IUSE=

pkg_postinst() {
	use prefix || enewgroup schedule
}
