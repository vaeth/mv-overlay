# Copyright 2016-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A wrapper script to set PAX kernel variables to an insecure/safe state"
HOMEPAGE="https://github.com/vaeth/paxopen/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE=""

src_install() {
	dosbin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
