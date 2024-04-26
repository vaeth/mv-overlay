# Copyright 2017-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: translate the selected text with www.linguee.com"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/traduza-para-mim/"
SRC_URI="https://addons.mozilla.org/firefox/downloads/file/4271772/traduza_para_mim-${PV}resigned1.xpi -> ${PN}-${PV}resigned1.xpi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 x86"
IUSE=""

INSTALL_ID='{e415fbdf-7d9b-4c89-bbf2-be52b470b1c1}'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
