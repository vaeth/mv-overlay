# Copyright 2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Use openrc init scripts with systemd or other init systems"
HOMEPAGE="https://github.com/vaeth/openrc-wrapper"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="!!<sys-fs/squash_dir-3.2"
# the last dependency is not really needed, but without it the output is ugly,
# and the costs are really not high: sys-apps/gentoo-functions is tiny
RDEPEND="${DEPEND}
|| ( sys-apps/gentoo-functions sys-apps/openrc )"
IUSE=""

src_install() {
	dodoc README
	systemd_dounit systemd/system/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	into /
	dobin bin/*
}
