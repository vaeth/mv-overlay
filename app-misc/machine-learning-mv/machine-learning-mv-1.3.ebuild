# Copyright 2017-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="Some machine learning experiments"
HOMEPAGE="https://github.com/vaeth/machine-learning-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE=""

RDEPEND=">=dev-lang/perl-5.12"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	default
}

src_install() {
	default
	dobin bin/*
	insinto /usr/share/zsh/site-functions
	doins zsh/_*
}
