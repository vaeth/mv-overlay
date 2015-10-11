# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"
inherit eutils

DESCRIPTION="A wrapper for cp -i -a, making use of diff"
HOMEPAGE="https://github.com/vaeth/cpi/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- bin/cpi || die
	epatch_user
}

src_install() {
	dobin bin/cpi
	insinto /usr/bin
	doins bin/mvi
	insinto /usr/share/zsh/site-functions
	doins zsh/*
}
