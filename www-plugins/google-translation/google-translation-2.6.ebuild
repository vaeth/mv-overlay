# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: translate to your native language a selected text"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/google-translation/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/727175/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

INSTALL_ID='gtranslation2@slam.com'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
