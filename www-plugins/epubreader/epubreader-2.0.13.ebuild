# Copyright 2014-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: read ebook (.epub) files"
HOMEPAGE="http://addons.mozilla.org/en-US/firefox/addon/epubreader/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/3594370/${PN//-/_}-${PV}.xpi"

LICENSE="epubreader"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults -i'{5384767E-00D9-40E9-B72F-9CC39D655D6F}' firefox seamonkey
