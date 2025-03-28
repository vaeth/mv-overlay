# Copyright 2014-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
# Do *not* inherit latex-package: It DEPENDS unconditionally on texinfo.
# Moreover, it would attempt to compile the *.tex example with texinfo to dvi.
RESTRICT="mirror"

DESCRIPTION="LaTeX2e character sheet layout for the Midgard Role Playing Game (Edition M5)"
HOMEPAGE="https://github.com/vaeth/m5figur-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LPPL-1.3c"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="+examples"
# We need texlive-latexextra for toolbox.sty
DEPEND="virtual/latex-base"
RDEPEND="${DEPEND}
	dev-texlive/texlive-latexextra"
BDEPEND="examples? ( ${DEPEND} )"

src_compile() {
	local i j
	if use examples
	then	einfo "Compiling example character sheet as pdf"
		export VARTEXFONTS="${T}/fonts"
		for i in *.tex beispiele/*.tex; do
			j=${i##*/}
			pdflatex "${i}" && test -s "${j%.tex}.pdf" \
				|| die "could not compile ${i}"
			[ "${j}" = "${i}" ] || mv "${j%.tex}.pdf" "${i%.tex}.pdf" || die
		done
	fi
}

src_install() {
	TEXMF="/usr/share/texmf-site"
	insinto "${TEXMF}/tex/latex/${PN}"
	doins *.cls
	insinto "${TEXMF}/doc/latex/${PN}"
	doins *.tex
	doins -r beispiele
	if use examples
	then	doins *.pdf
	fi
	dodoc README.md
}

pkg_postinst() {
	texconfig rehash
}

pkg_postrm() {
	texconfig rehash
}
