# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1 readme.gentoo-r1
RESTRICT="mirror"

DESCRIPTION="Firefox webextension: install themes and skins for many popular sites"
HOMEPAGE="https://addons.mozilla.org/en-US/firefox/addon/styl-us/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/814814/${PN}_beta-${PV}-an+fx.xpi"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="You will probably want to setup the \"Darker forum\" style.
The old version could be found at
	http://jesgue.homelinux.org/other-files/dark-gentoo-forums.css
but meanwhile it is easier to surf with javascript activated to
	http://userstyles.org/users/8172
Note that you have to temporarily disable noscript for that site."

INSTALL_ID=-i'{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}'

moz_defaults "${INSTALL_ID}" firefox seamonkey

src_install() {
	moz_install "${INSTALL_ID}"
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
