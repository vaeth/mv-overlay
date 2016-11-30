# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin: Restrict active contents like java/javascript/flash"
HOMEPAGE="http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${PV}-fx+fn+sm.xpi -> ${P}.xpi"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey

RDEPEND="${RDEPEND}
browser_firefox? ( !www-plugins/noscript:0[browser_firefox] )
browser_firefox-bin? ( !www-plugins/noscript:0[browser_firefox-bin] )
browser_seamonkey? ( !www-plugins/noscript:0[browser_seamonkey] )
browser_seamonkey-bin? ( !www-plugins/noscript:0[browser_seamonkey-bin] )"
