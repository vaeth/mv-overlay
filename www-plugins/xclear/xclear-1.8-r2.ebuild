# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox plugin: button to clear URL"
HOMEPAGE="http://addons.mozilla.org/firefox/addon/xclear/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/13078/${P}-sm+fx.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults
