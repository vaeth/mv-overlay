# Copyright 2014-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: read ebook (.epub) files"
HOMEPAGE="http://addons.mozilla.org/en-US/firefox/addon/epubreader/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/45281/${P}-an+fx.xpi"

LICENSE="epubreader"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults -i'{5384767E-00D9-40E9-B72F-9CC39D655D6F}' firefox seamonkey
