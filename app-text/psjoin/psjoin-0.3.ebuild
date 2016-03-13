# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"

DESCRIPTION="concatenate postscript files. From new PostScript Utilities"
HOMEPAGE="http://t-sato.in.coocan.jp/tools/psjoin.html"
SRC_URI="http://t-sato.in.coocan.jp/tools/${PN} -> ${P}.pl"

LICENSE="psutils"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-lang/perl"

src_unpack() {
	mkdir --  "${S}"
	cp -p -- "${DISTDIR}/${P}.pl" "${S}/${PN}"
}

src_install() {
	dobin "${PN}"
}
