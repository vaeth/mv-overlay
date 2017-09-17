# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="<firefox-57 add-on: control cross-site requests (increases privacy/security)"
HOMEPAGE="https://www.requestpolicy.com/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/9727/${P}-sm+fx.xpi"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' palemoon seamonkey
