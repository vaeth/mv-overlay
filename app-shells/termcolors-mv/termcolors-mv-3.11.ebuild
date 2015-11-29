# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit readme.gentoo

DESCRIPTION="256colors sample script and dircolors configuration for standard or 256 colors"
HOMEPAGE="https://github.com/vaeth/termcolors-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="create +perl"
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
	eapply_user
}

src_compile() {
	perl bin/DIR_COLORS-create
}

src_install() {
	dodoc README
	dobin bin/dircolors-mv
	use create && dobin bin/DIR_COLORS-create
	use perl && dobin bin/256colors
	insinto /etc/dir_colors
	doins DIR_COLORS*
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
