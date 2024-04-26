# Copyright 2010-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: restrict active contents like java/javascript/flash"
HOMEPAGE="https://addons.mozilla.org/de/firefox/addon/noscript/
http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.mozilla.org/firefox/downloads/file/4206186/${PN//-/_}-${PV}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults -i'{73a6fe31-595d-460b-a920-fcc0f8843232}' '>=firefox-59' seamonkey
