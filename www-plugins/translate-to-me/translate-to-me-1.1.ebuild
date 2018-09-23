# Copyright 2017-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: translate the selected text with www.linguee.com"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/traduza-para-mim/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/759684/traduza_para_mim-${PV}-an+fx.xpi -> translate_to_me-${PV}.xpi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

INSTALL_ID='{e415fbdf-7d9b-4c89-bbf2-be52b470b1c1}'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
