# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

MY_P="${P/-/_}"
NAME="${MY_P}-fx.xpi"
DESCRIPTION="Firefox webextension: translate the selected text with www.linguee.com"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/bookmark-dupes/
https://github.com/vaeth/bookmarkdupes/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/870263/${NAME}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

INSTALL_ID='bookmarkdupes@martin-vaeth.org'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
