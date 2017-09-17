# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

MY_P="${P/-/_}"
NAME="${MY_P}-fx.xpi"
DESCRIPTION="<firefox-57 add-on: deduplicate your bookmarks"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/bookmark-deduplicator/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/422748/${NAME}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' palemoon
