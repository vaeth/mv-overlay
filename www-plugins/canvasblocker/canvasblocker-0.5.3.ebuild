# Copyright 2017-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: block canvas API to prevent canvas fingerprinting"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/canvasblocker/
https://github.com/kkapsner/CanvasBlocker"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/534930/${PN//-/_}-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

moz_defaults firefox seamonkey
