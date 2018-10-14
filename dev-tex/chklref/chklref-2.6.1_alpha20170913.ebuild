# Copyright 2010-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit latex-package
RESTRICT="mirror"

DESCRIPTION="Finds useless references in latex files or unnecessarily numbered environments"
HOMEPAGE="https://github.com/jlelong/chklref/"
case ${PV} in
*alpha*)
	EGIT_COMMIT="23028ecbeff38429d1e91a7e142d2bdc623298d8"
	SRC_URI="https://github.com/jlelong/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
*)
	SRC_URI="https://github.com/jlelong/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz";;
esac

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="virtual/latex-base
	dev-lang/perl"
BDEPEND="${RDEPEND}"

DOCS=( README.md )
ver_test "${PV}" -gt 2.6.0 || DOCS=( README )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${S}"/src/chklref.in || die
	default
}

src_configure() {
	econf --with-texmf-prefix="${EPREFIX}${TEXMF}"
}

src_compile() {
	default
}

src_install() {
	default
}
