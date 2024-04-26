# Copyright 2018-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: calculate values of mathematical expressions"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/calc-extension/
https://github.com/vaeth/calc-extension/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/4274613/${PN//-/_}-${PV}resigned1.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults -i'calc@martin-vaeth.org' firefox seamonkey
