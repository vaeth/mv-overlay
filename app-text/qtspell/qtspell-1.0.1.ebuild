# Copyright 1999-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

inherit cmake flag-o-matic

DESCRIPTION="Spell checking for Qt text widgets"
HOMEPAGE="https://github.com/manisandro/qtspell"
SRC_URI="https://github.com/manisandro/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

RDEPEND="app-text/enchant"
DEPEND="${RDEPEND}"

src_prepare() {
	filter-flags '-flto*' '-fuse-linker-plugin' '-emit-llvm'
	cmake_src_prepare
}
