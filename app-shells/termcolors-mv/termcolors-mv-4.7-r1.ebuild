# Copyright 2013-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit readme.gentoo-r1

DESCRIPTION="256colors sample script and dircolors configuration for standard or 256 colors"
HOMEPAGE="https://github.com/vaeth/termcolors-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="create +perl poor"
DEPEND="dev-lang/perl"
RDEPEND="create? ( dev-lang/perl )
perl? ( dev-lang/perl )"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To use the colorschemes of ${PN} call
	eval \"\`dircolors-mv\`\"
e.g. in your bashrc; make sure that SOLARIZED (if desired)
and DEFAULTS is set appropriately, see the documentation.
For zsh, this happens if you use zshrc-mv"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	default
}

src_compile() {
	perl bin/DIR_COLORS-create $(usex poor poor '')
}

src_install() {
	dodoc README.md
	dobin bin/dircolors-mv
	use create && dobin bin/DIR_COLORS-create
	use perl && dobin bin/256colors
	insinto /usr/lib/dir_colors
	doins DIR_COLORS*
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
