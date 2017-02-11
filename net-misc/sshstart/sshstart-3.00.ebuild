# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="Start ssh-agent/ssh-add only if you really use ssh or friends"
HOMEPAGE="https://github.com/vaeth/sshstart/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+keychain"
RDEPEND=">=app-shells/push-2.0-r2
	keychain? ( net-misc/keychain )"
DEPEND=""

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${PN}" || die
	eapply_user
}

src_install() {
	dobin "${PN}"
	dodoc README
}
