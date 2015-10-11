# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Check for hardened protections like RELRO, NoExec, Stack protection, ASLR, PIE"
HOMEPAGE="http://www.trapkit.de/tools/checksec.html"
SRC_URI="http://www.trapkit.de/tools/${PN}.sh -> ${P}.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"

src_prepare() {
	epatch_user
}

src_install() {
	newbin "${DISTDIR}/${P}.sh" "${PN}"
	insinto /usr/share/zsh/site-functions
	doins "${FILESDIR}/_${PN}"
}
