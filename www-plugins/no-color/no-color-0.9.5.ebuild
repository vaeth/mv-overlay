# Copyright 2017-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: remove colors and background images from the page"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/no-color/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/4270252/${PN//-/_}-${PV}resigned1.xpi"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

moz_defaults -i'{ae443e4d-02db-4eef-bcc2-0f1b17edb941}' firefox seamonkey
