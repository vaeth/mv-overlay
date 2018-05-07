# Copyright 2017-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: avoid centralized services"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/decentraleyes/
https://github.com/Synzvato/decentraleyes"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/521554/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults firefox seamonkey
