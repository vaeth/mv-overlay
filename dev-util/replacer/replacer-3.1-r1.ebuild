# Copyright 2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

DESCRIPTION="Search and replace python regular expressions within many files interactively"
HOMEPAGE="https://github.com/vaeth/replacer/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"
PLOCALES="de"
for i in ${PLOCALES}; do
	IUSE+=" l10n_${i}"
done

RDEPEND="dev-lang/python
	nls? ( virtual/libintl )"
BDEPEND="nls? ( sys-devel/gettext )"

src_prepare() {
	local r
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
		bin/* || die
	if use nls; then
		localepath=${EPREFIX}/usr/share/locale
		r="'${localepath}'"
	else
		r='None'
	fi
	sed -i \
		-e 's"^\(localedir[[:space:]]*=[[:space:]]*\).*"\1'"${r}\"" \
		bin/${PN} || die
	default
}

src_install() {
	local i
	if use nls; then
		export LINGUAS=
		for i in ${PLOCALES}; do
			use l10n_${i} && LINGUAS+=${LINGUAS:+ }${i}
		done
		po/install-mo "${D}${localepath}"
	fi
	dobin bin/*
	dodoc README.md
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
