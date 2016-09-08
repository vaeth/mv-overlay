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
IUSE="+portage-utils"

src_prepare() {
	use prefix || {
		sed -i \
				-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
				-- etc/portage/repo.postsync.d/*-* || die
		sed -i \
			-e '1s"^#!/usr/bin/env $"#!'"${EPREFIX}/usr/bin/"'"' \
				-- usr/bin/* || die
	}
	eapply_user
}

src_install() {
	exeinto /usr/bin
	doexe usr/bin/*
	dodoc README
	insinto /etc/portage/repo.postsync.d
	doins etc/portage/repo.postsync.d/*.sh
	doins etc/portage/repo.postsync.d/README
	docompress /etc/portage/repo.postsync.d/README
	exeinto /etc/portage/repo.postsync.d
	doexe etc/portage/repo.postsync.d/[0-9]*
	insinto /usr/lib/portage-postsyncd-mv
	doins etc/portage/env/app-portage/portage-utils
	! use portage-utils || \
		dosym "${EPREFIX}"/usr/lib/portage-postsyncd-mv/portage-utils \
			/etc/portage/env/app-portage/portage-utils
}

pkg_postinst() {
	local f g h
	f="${EPREFIX}"/etc/portage/repo.postsync.d/q-reinit
	if test -x "$f"
	then	if use portage-utils
		then	chmod a-x -- "${f}"
		else	elog "It is recommended to call"
			elog "	chmod a-x -- \"${f}\""
			elog "to let portage-postsyncd-mv determine the order of execution."
		fi
	fi
	if ! use portage-utils
	then	h="${EPREFIX}"/etc/portage/env/app-portage
		test -h "$h"/portage-utils || {
			g=/usr/lib/portage-postsyncd-mv/portage-utils
			elog "It is recommended to call"
			elog "	mkdir -p ${EPREFIX:+-- \"}${h}${EPREFIX:+\"}"
			elog "	ln -s ${EPREFIX:+-- \"}${g}${EPREFIX:+\"} \\"
			elog "		${EPREFIX:+\"}${h}${EPREFIX:+\"}"
			elog "to keep $f non-executable"
			elog "after a future emerge of app-portage/portage-utils"
		}
	fi
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
