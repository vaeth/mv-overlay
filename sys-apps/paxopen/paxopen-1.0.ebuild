# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="A wrapper script to set PAX kernel variables to an insecure/safe state"
HOMEPAGE="https://github.com/vaeth/paxopen/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	dosbin "${PN}"
	insinto /usr/share/zsh/site-functions
	doins _"${PN}"
}
