# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
EGIT_REPO_URI="git://aufs.git.sourceforge.net/gitroot/aufs/aufs-util.git"
EGIT_BRANCH="aufs3.9"
inherit eutils git-r3 linux-info multilib

DESCRIPTION="Userspace tools for aufs"
HOMEPAGE="http://aufs.sourceforge.net/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0/3.9"
# Since this is a live ebuild, we require ACCEPT_KEYWORDS='**'
#KEYWORDS="~amd64 ~x86"
KEYWORDS=""
IUSE=""
PROPERTIES="live"

RDEPEND=""
DEPEND="dev-vcs/git[curl]"

src_prepare() {
	local i l
	ln -s "${KERNEL_DIR}"/include local_kernel
	set -- local_kernel/linux/aufs*.h
	test -e "${1}" || {
		eerror "It seems you do not have installed aufs into your kernel tree."
		die "You might need to emerge >=sys-fs/aufs-99999999::mv"
	}
	l="s|/usr/lib|$(get_libdir)|"
	sed -i -e "1iCFLAGS += -I./local_kernel -include linux/compiler.h" -e "${l}" Makefile || \
		die "Patching Makefile failed"
	for i in lib*/Makefile
	do	test -e "${i}" || continue
		sed -i -e "1iCFLAGS += -I../local_kernel" -e "${l}" "${i}" || \
			die "Patching ${i} failed"
	done
	epatch_user
}
