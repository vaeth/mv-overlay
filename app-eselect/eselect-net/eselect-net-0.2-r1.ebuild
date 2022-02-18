# Copyright 2016-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="eselect module for managing network open-rc service configurations"
HOMEPAGE="https://github.com/reith/eselect-net/"
SRC_URI="https://github.com/reith/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DOCS=(README.md)

src_install() {
	insinto /usr/share/eselect/modules
	doins net.eselect
	dodir /etc/eselect/net/devs /etc/eselect/net/conf.d
}
