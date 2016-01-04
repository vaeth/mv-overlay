# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
# Do *not* inherit latex-package: It DEPENDS unconditionally on texinfo.
# Moreover, it would attempt to compile the *.tex example with texinfo to dvi.
RESTRICT="mirror"

DESCRIPTION="LaTeX2e character sheet layout for the Midgard Role Playing Game (Edition M5)"
HOMEPAGE="https://github.com/vaeth/m5figur-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LPPL-1.2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+examples"
# We need texlive-latexextra for toolbox.sty
RDEPEND="virtual/latex-base
	dev-texlive/texlive-latexextra"
DEPEND="examples? ( ${RDEPEND} )"

src_compile() {
	if use examples
	then	einfo "Compiling example character sheet as pdf"
		export VARTEXFONTS="${T}/fonts"
		pdflatex *.tex && test -s *.pdf || die "could not create example"
	fi
}

src_install() {
	TEXMF="/usr/share/texmf-site"
	insinto "${TEXMF}/tex/latex/${PN}"
	doins *.cls
	insinto "${TEXMF}/doc/latex/${PN}"
	doins *.tex
	if use examples
	then	doins *.pdf
	fi
	dodoc README
}

pkg_postinst() {
	texconfig rehash
}

pkg_postrm() {
	texconfig rehash
}
