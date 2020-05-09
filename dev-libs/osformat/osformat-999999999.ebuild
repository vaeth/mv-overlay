# Copyright 2017-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/vaeth/${PN}.git"
	inherit git-r3
	SRC_URI=""
	PROPERTIES="live";;
*)
	RESTRICT="mirror"
	EGIT_COMMIT="7ea6497698b11fa3289b223b2e2d487500dcaa10"
	SRC_URI="https://github.com/vaeth/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
esac

DESCRIPTION="C++ library for a typesafe printf/sprintf based on << conversion"
HOMEPAGE="https://github.com/vaeth/osformat/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
