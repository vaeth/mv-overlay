# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MY_PN=${PN}.sh
DESCRIPTION="Tool to check properties of executables (e.g. ASLR/PIE, RELRO, PaX, Canaries)"
HOMEPAGE="https://github.com/slimm609/checksec.sh"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test update"
DEPEND="test? ( dev-python/demjson dev-libs/libxml2 )"

case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/slimm609/${MY_PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	RESTRICT="mirror"
	SRC_URI="https://github.com/slimm609/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	S=${WORKDIR}/${MY_PN}-${PV}
esac

DOCS=( ChangeLog README.md )

src_prepare() {
	if ! use update
	then	sed -i -e '/--update/d' extras/zsh/_${PN} || die
		sed -i -e 's/^\([ 	]*pkg_release=\)false/\1true/' ${PN} || die
	fi
	eapply_user
}

src_install() {
	dobin ${PN}
	insinto /usr/share/zsh/site-functions
	doins extras/zsh/_${PN}
	einstalldocs
	doman extras/man/*
}

src_test() {
	cd tests || return 0
	./test-checksec.sh || die
}
