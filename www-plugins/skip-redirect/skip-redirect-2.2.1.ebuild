# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: skip intermediary pages before redirecting"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/skip-redirect/
https://github.com/sblask/webextension-skip-redirect"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/642100/${PN//-/_}-${PV}-fx.xpi"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
