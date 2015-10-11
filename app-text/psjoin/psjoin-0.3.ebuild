# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
RESTRICT="mirror"

inherit eutils

DESCRIPTION="concatenate postscript files. From new PostScript Utilities"
HOMEPAGE="http://homepage3.nifty.com/tsato/tools/psjoin.html"
SRC_URI="http://homepage3.nifty.com/tsato/tools/${PN} -> ${P}"

LICENSE="psutils"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/perl"

src_unpack() {
	mkdir --  "${S}"
	cp -p -- "${DISTDIR}/${P}" "${S}/${PN}"
}

src_prepare() {
	epatch_user
}

src_install() {
	dobin "${PN}"
}
