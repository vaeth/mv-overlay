# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit vcs-snapshot

DESCRIPTION="eselect module for managing network open-rc service configurations"
HOMEPAGE="https://github.com/reith/eselect-net/"
SRC_URI="https://github.com/reith/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE=""

DOCS=(README.md)

src_install() {
	insinto /usr/share/eselect/modules
	doins net.eselect
	dodir /etc/eselect/net/devs /etc/eselect/net/conf.d
}
