# Copyright 2017-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: a global dark theme for the web"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/dark-mode-webextension/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/3970612/${PN//-/_}_webextension-0.4.5.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults -i'{174b2d58-b983-4501-ab4b-07e71203cb43}' firefox seamonkey
