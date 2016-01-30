# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mv_mozextension-r1 readme.gentoo-r1
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin to modify style of certain web pages (e.g. Gentoo forums)"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/stylish/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/2108/${P}-fx+sm+tb+an.xpi -> ${P}.xpi"

LICENSE="GPL-2"
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

moz_defaults

src_install() {
	moz_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
