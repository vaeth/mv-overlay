# Copyright 2017-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

SRC_URI="https://github.com/vaeth/osformat/releases/download/v${PV}/${P}.tar.xz"

DESCRIPTION="C++ library for a typesafe printf/sprintf based on << conversion"
HOMEPAGE="https://github.com/vaeth/osformat/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
