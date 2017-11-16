# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

MY_P="${P/-/_}"
MY_P="${MY_P/-/_}"
NAME="${MY_P}-fx.xpi"
DESCRIPTION="Firefox legacy add-on: remove duplicate bookmarks"
HOMEPAGE="https://addons.mozilla.org/de/firefox/addon/bookmark-duplicate-cleaner/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/416156/${NAME}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' palemoon
