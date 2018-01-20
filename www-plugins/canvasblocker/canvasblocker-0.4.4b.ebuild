# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: block canvas API to prevent canvas fingerprinting"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/canvasblocker/
https://github.com/kkapsner/CanvasBlocker"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/534930/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
