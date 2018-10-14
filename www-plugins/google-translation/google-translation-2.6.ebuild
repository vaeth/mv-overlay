# Copyright 2017-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: translate to your native language a selected text"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/google-translation/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/727175/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

INSTALL_ID='gtranslation2@slam.com'

moz_defaults -i"${INSTALL_ID}" firefox seamonkey
