# Copyright 2017-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: An efficient list-based blocker"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/607454/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
