# Copyright 2017-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: open selected text or webpage in google translator"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/open-in-google-translate/
http://mybrowseraddon.com/open-in-gtranslate.html"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/694452/open_in_googletm_translate-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

INSTALL_ID='jid1-r2tWDbSkq8AZK1@jetpack'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
