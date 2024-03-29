# Copyright 2017-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: remove colors and background images from the page"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/no-color/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/5758/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults firefox seamonkey
