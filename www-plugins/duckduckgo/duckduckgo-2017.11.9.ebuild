# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

mPN="${PN}_plus-${PV}"
DESCRIPTION="Firefox webextension: enable duckduckgo search engine"
HOMEPAGE="http://addons.mozilla.org/en-US/firefox/addon/duckduckgo-for-firefox/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/385621/${mPN}-an+fx.xpi"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '>=firefox-57' seamonkey
