# Copyright 1999-2020 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit toolchain-funcs

MY_P=${PN}-1.0.a15unix

DESCRIPTION="Utility for displaying AVI information"
HOMEPAGE="http://shounen.ru/soft/avinfo/english.shtml"
SRC_URI="http://shounen.ru/soft/${PN}/${MY_P}.tar.gz
	http://shounen.ru/soft/${PN}/${MY_P}-patch1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

S="${WORKDIR}"/${PN}-1.0.a15

src_prepare() {
	eapply "${WORKDIR}"/${MY_P}-patch1/${MY_P}-patch1.diff
	eapply "${FILESDIR}"/no-bison.patch
	eapply "${FILESDIR}"/no-common.patch
	sed -i -e 's/$(CC) $(OBJ)/$(CC) $(LDFLAGS) $(OBJ)/' src/Makefile || die
	default
}

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}"
}

src_install() {
	dobin src/avinfo
	doman src/avinfo.1
	dodoc CHANGELOG README "${WORKDIR}"/${MY_P}-patch1/FIXES
	dodoc doc/*
}
