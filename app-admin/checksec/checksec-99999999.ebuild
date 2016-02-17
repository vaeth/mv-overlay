# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MY_PN=${PN}.sh
DESCRIPTION="Tool to check properties of executables (e.g. ASLR/PIE, RELRO, PaX, Canaries)"
HOMEPAGE="https://github.com/slimm609/checksec.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="vanilla"

case ${PV} in
99999999*)
	LIVE=:
	EGIT_REPO_URI="git://github.com/slimm609/${MY_PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	LIVE=false
	#RESTRICT="mirror"
	SRC_URI="https://github.com/slimm609/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}"/${MY_PN}-${PV}
esac


DOCS=( ChangeLog README.md )

src_prepare() {
	eapply "${FILESDIR}"/path.patch
	if ! use vanilla
	then	sed -e '/--update/d' "${FILESDIR}/_${PN}" >_${PN} || die
		sed -i -e '/--update.*)/,/;;/d' ${PN} || die
	fi
	eapply_user
}

src_install() {
	dobin ${PN}
	insinto /usr/share/zsh/site-functions
	doins _${PN}
	einstalldocs
}
