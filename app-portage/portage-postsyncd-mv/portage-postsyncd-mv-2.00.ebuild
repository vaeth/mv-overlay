# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="postsync hooks for portage to sync from git"
HOMEPAGE="https://github.com/vaeth/portage-postsyncd-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_prepare() {
	use prefix || sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- etc/portage/repo.postsync.d/*-* || die
	eapply_user
}

src_install() {
	dodoc README
	insinto /etc/portage/repo.postsync.d
	doins etc/portage/repo.postsync.d/README
	docompress /etc/portage/repo.postsync.d/README
	exeinto /etc/portage/repo.postsync.d
	doexe etc/portage/repo.postsync.d/*-*
	insinto /lib/gentoo
	doins lib/gentoo/*
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS}" in
	*' 0.'*|*' 1.'*)
		ewarn "The previous versions of $PN had several bugs."
		ewarn 'It is recommended to remove from $PORTDIR/metadata the directories'
		ewarn '	dtd/ glsa/ news/ xml-schema/'
		ewarn 'as well as the directory $PORTDIR/local/timestamps'
		ewarn 'to make sure that these directories contain the correct content.'
	;;
	esac
}
