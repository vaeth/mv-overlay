# Copyright 2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox legacy add-on: restrict active contents like java/javascript/flash"
HOMEPAGE="http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${PV}-fx+sm.xpi -> ${P}.xpi"

LICENSE="GPL-2"
SLOT="legacy"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' '>=palemoon-27'
