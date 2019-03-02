# Copyright 2010-2019 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
WANT_LIBTOOL=none
AUTOTOOLS_IN_SOURCE_BUILD=true
inherit autotools eutils linux-info readme.gentoo-r1 systemd

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="aufs overlayfs bundled-openrc-wrapper unionfs-fuse"

DEPEND="bundled-openrc-wrapper? ( !!sys-apps/openrc-wrapper )"
RDEPEND="sys-fs/squashfs-tools
	!bundled-openrc-wrapper? ( sys-apps/openrc-wrapper )
	${BOTHDEPEND}
	>=app-shells/runtitle-2.3
	!<sys-fs/unionfs-fuse-0.25
	unionfs-fuse? ( sys-fs/unionfs-fuse )"
BDEPEND=">=sys-devel/autoconf-2.65"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="Please adapt ${EPREFIX}/etc/conf.d/${PN} to your needs.
It is recommended to put into your zshrc the line:
alias squash_dir='noglob squash_dir'"

src_prepare() {
	if use prefix
	then	sed -i \
			-e "s\"'[^']*/etc/conf[.]d/${PN}'\"'${EPREFIX}/etc/conf.d/${PN}'\"g" \
			-- "init.d/${PN}" || die
		sed -i \
			-e "s\"=/etc/\"=${EPREFIX}/etc/\"" \
			-e "s\"=/usr/\"=${EPREFIX}/usr/\"" \
			-- "systemd/${PN}@.service" || die
		sed -i \
			-e "s\":/usr/sbin:/sbin'\":${EPREFIX}/usr/sbin:${EPREFIX}/sbin:/usr/sbin:/sbin'\"" \
			-- "sbin/${PN}" || die
		sed -i \
			-e "s\"'/lib\"'${EPREFIX}/lib64/rc/bin:${EPREFIX}/lib/rc/bin:/lib\"" \
			-- "bin/openrc-wrapper" || die
	else	sed -i \
			-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
			-- bin/* sbin/* || die
	fi
	default
	eautoreconf
}

src_configure() {
	local order=
	use unionfs-fuse && order=unionfs-fuse
	use aufs && order=aufs
	use overlayfs && order=overlayfs
	econf --with-zsh-completion \
		"$(use_enable bundled-openrc-wrapper openrc-wrapper)" \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		--bindir=/bind \
		${order:+"--with-first-order=${order}"}
}

src_install() {
	default
	readme.gentoo_create_doc
}

linux_config_missing() {
	! linux_config_exists || ! linux_chkconfig_present "${1}"
}

pkg_postinst() {
	local fs=overlayfs
	use unionfs-fuse && fs=unionfs-fuse
	use aufs && fs=aufs
	use overlayfs && fs=overlayfs
	if linux_config_missing 'SQUASHFS'
	then	ewarn "To use ${PN} activate squashfs in your kernel"
	fi
	case ${fs} in
	overlayfs)
		if linux_config_missing 'OVERLAYFS_FS'
		then	ewarn "To use ${PN} activate overlayfs in your kernel."
			ewarn "Unless you use a patched kernel, apply e.g. top patches from some head of"
			ewarn "https://git.kernel.org/?p=linux/kernel/git/mszeredi/vfs.git;a=summary"
		fi;;
	aufs)
		if ! has_version sys-fs/aufs3 && ! has_version sys-fs/aufs2 && linux_config_missing 'AUFS_FS'
		then	ewarn "To use ${PN} activate aufs in your kernel. Use e.g. sys-fs/aufs*"
		fi;;
	esac
	optfeature "improved output" 'sys-fs/squashfs-tools[progress-redirect]'
	optfeature "status bar support" 'app-shells/runtitle'
	readme.gentoo_print_elog
}
