# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
DESCRIPTION="German dictionary (traditional orthography) for ispell"
HOMEPAGE="http://www.lasr.cs.ucla.edu/geoff/ispell-dictionaries.html"
SRC_URI="ftp://ftp.informatik.uni-kiel.de/pub/kiel/dicts/hk${PV}-deutsch.tar.gz
	http://www.j3e.de/ispell/hk2/hkgerman_2-patch-bj1.diff.gz"

# GPL according to <http://bugs.debian.org/131124#25>
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ~mips ppc sparc x86"
IUSE=""

BDEPEND="app-text/ispell:="
RDEPEND="${BDEPEND}"

S="${WORKDIR}"

PATCHES=(hkgerman_2-patch-bj1.diff)

src_install() {
	insinto /usr/$(get_libdir)/ispell
	doins deutsch.aff deutsch.hash
	dosym deutsch.aff /usr/$(get_libdir)/ispell/de_DE_1901.aff
	dosym deutsch.hash /usr/$(get_libdir)/ispell/de_DE_1901.hash
	dodoc ANNOUNCE Changes Contributors README*
}
