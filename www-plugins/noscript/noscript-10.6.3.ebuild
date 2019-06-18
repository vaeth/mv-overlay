# Copyright 2010-2019 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: restrict active contents like java/javascript/flash"
HOMEPAGE="http://noscript.net/"
SRC_URI="https://secure.informaction.com/download/releases/${P}.xpi
https://addons.cdn.mozilla.net/user-media/addons/722/noscript_security_suite-${PV}-an+fx.xpi -> ${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

moz_defaults '>=firefox-59' seamonkey
