# Copyright 2013-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit systemd

DESCRIPTION="Use openrc init scripts with systemd or other init systems"
HOMEPAGE="https://github.com/vaeth/openrc-wrapper"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="split-usr"

# The dependency is not really needed, but without it the output is ugly,
# and the costs are really not high: sys-apps/gentoo-functions is tiny
RDEPEND="|| ( sys-apps/gentoo-functions sys-apps/openrc )"
DEPEND=""

src_prepare() {
	sed -i -e "s'ExecStart=/bin'ExecStart=$(get_usr)/bin'" \
		"${S}"/systemd/system/*.service
	default
}

src_install() {
	dodoc README.md
	systemd_dounit systemd/system/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	into $(get_usr)/
	dobin bin/*
}

get_usr() {
	use split-usr || echo /usr
}
