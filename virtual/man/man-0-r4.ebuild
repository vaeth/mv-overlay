# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for man"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"

HOMEPAGE=
SRC_URI=
LICENSE=
IUSE=

RDEPEND="
	|| (
		>=app-text/mandoc-1.14.5-r1[system-man]
		sys-apps/man
		sys-apps/man-db
	)
"
