# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit eutils readme.gentoo-r1

DESCRIPTION="Frontends for using mplayer/mencoder, ffmpeg/libav, or tzap as video recorder"
HOMEPAGE="https://github.com/vaeth/video-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND=">=app-shells/push-2.0
	>=app-shells/runtitle-2.3
	|| ( ( media-sound/alsa-utils
			|| ( media-video/mplayer[encode] virtual/ffmpeg ) )
		media-tv/linuxtv-dvb-apps )"
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="If you use dvb-t with zsh completion, you might want to put
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
into your ~/.zshrc or /etc/zshrc for case-insensitive matching."

src_prepare() {
	local i
	use prefix || for i in bin/*
	do	test -h "${i}" || sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-e 's"^\. _videoscript\.sh$". '"${EPREFIX}/usr/share/video-mv/_videoscript.sh"'"' \
			-- "${i}" || die
	done
	eapply_user
}

src_install() {
	local i
	insinto /usr/bin
	for i in bin/*
	do	if test -h "${i}"
		then	doins "${i}"
		elif [ "${i#*/}" != '_videoscript.sh' ]
		then	dobin "${i}"
		fi
	done
	insinto /usr/share/video-mv
	doins bin/_videoscript.sh
	insinto /etc
	doins etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	dodoc README
	readme.gentoo_create_doc
}

pkg_postinst() {
	optfeature "status bar support" app-shells/runtitle
	readme.gentoo_print_elog
}
