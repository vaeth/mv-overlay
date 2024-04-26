# Copyright 2017-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: remove duplicate bookmarks/empty folders/descriptions"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/bookmark-dupes/
https://github.com/vaeth/bookmarkdupes/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/3982686/${P}.xpi"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults firefox seamonkey
