# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGIT_REPO_URI="git://github.com/mozilla/shumway.git"
inherit mv_mozextension
#inherit git-r3

DESCRIPTION="Mozilla plugin: Flashplayer emulation with javascript and html5"
HOMEPAGE="http://mozilla.github.io/shumway/"
SRC_URI="http://mozilla.github.io/shumway/extension/firefox/${PN}.xpi -> ${P}.xpi"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
