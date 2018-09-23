# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit desktop
RESTRICT="mirror"

DESCRIPTION="Sierra script interpreter for your old Sierra adventures"
HOMEPAGE="http://freesci.linuxgames.com/"
SRC_URI="http://www-plan.cs.colorado.edu/creichen/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="X ggi sdl"

DEPEND="media-libs/alsa-lib
	X? (
		x11-libs/libX11
		x11-libs/libXrender
		x11-libs/libXext
	)
	ggi? ( media-libs/libggi )
	sdl? ( media-libs/libsdl )"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i \
		-e "/^SUBDIRS =/s:desktop src conf debian:src:" \
		Makefile.in \
		|| die "sed failed"
	eapply -p0 "${FILESDIR}"/${P}-glibc2.10.patch
	default
}

src_configure() {
	econf \
		--with-Wall \
		--without-directfb \
		$(use_with X x) \
		$(use_with ggi) \
		$(use_with sdl)
}

src_install() {
	default
	doicon desktop/${PN}.png
	make_desktop_entry ${PN} FreeSCI
}
