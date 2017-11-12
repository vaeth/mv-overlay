# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="<firefox-57 add-on: read ebook (.epub) files"
HOMEPAGE="http://addons.mozilla.org/de/firefox/addon/epubreader/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/45281/${P}-fx+sm.xpi"

LICENSE="epubreader"
SLOT="palemoon"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' palemoon seamonkey
