# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"

DESCRIPTION="An intelligent prompt for zsh or bash with status line (window title) support"
HOMEPAGE="https://github.com/vaeth/set_prompt/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}"'/bin/sh"' \
		-e '1s"^#!/usr/bin/env zsh$"#!'"${EPREFIX}"'/bin/zsh"' \
		-- * || die
	eapply_user
}

src_install() {
	insinto /etc
	doins set_prompt.config
	insinto /usr/bin
	doins set_prompt.sh git_prompt.zsh
	dobin set_prompt git_update
	dodoc README
}
