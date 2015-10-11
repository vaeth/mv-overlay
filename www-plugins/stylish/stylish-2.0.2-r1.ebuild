# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mv_mozextension readme.gentoo
RESTRICT="mirror"

DESCRIPTION="Mozilla plugin to modify style of certain web pages (e.g. Gentoo forums)"
HOMEPAGE="https://addons.mozilla.org/firefox/addon/stylish/"
SRC_URI="http://addons.cdn.mozilla.net/user-media/addons/2108/${P}-fx+an+sm+tb.xpi"

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

src_install() {
	mv_mozextension_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_pkg_postinst
}
