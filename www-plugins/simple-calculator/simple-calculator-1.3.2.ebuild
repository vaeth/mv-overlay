# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: A basic simple math calculator"
HOMEPAGE="https://addons.mozilla.org/de/firefox/addon/simple-calculator-1_blacktoy/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/562742/${PN//-/_}-${PV}-an+fx-linux.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
