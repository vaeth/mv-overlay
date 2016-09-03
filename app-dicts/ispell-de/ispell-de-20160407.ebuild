# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
MY_P=igerman98-${PV}

DESCRIPTION="German and Swiss dictionaries for ispell"
HOMEPAGE="http://j3e.de/ispell/igerman98/"
SRC_URI="http://j3e.de/ispell/igerman98/dict/${MY_P}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
IUSE=""
KEYWORDS="alpha amd64 hppa mips ppc sparc x86"

DEPEND="app-text/ispell:="

S=${WORKDIR}/${MY_P}

src_compile() {
	for lang in de_DE de_AT de_CH; do
		emake ispell/${lang}{.aff,.hash}
	done
}

src_install () {
	insinto /usr/$(get_libdir)/ispell
	for lang in de_DE de_AT de_CH; do
		doins ispell/${lang}{.aff,.hash}
	done

	dodoc Documentation/*
	rm -f -- "${ED}/usr/share/doc/${PF}/GPL"*
}
