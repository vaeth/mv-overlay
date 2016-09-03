# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils

DESCRIPTION="3d tron, just like the movie"
HOMEPAGE="http://gltron.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.tar.gz
	mirror://gentoo/${PN}.png"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="virtual/opengl
	media-libs/libpng:0
	media-libs/libsdl[sound,video]
	media-libs/sdl-mixer[vorbis]
	media-libs/sdl-sound[vorbis,mikmod]
	media-libs/smpeg
	media-libs/libmikmod"
RDEPEND=${DEPEND}

src_prepare() {
	eapply -p0 "${FILESDIR}"/${P}-configure.patch
	eapply -p0 "${FILESDIR}"/${P}-prototypes.patch
	eapply -p0 "${FILESDIR}"/${P}-debian.patch
	eapply "${FILESDIR}"/${P}-gcc49.patch
	sed -i \
		-e '/^gltron_LINK/s/$/ $(LDFLAGS)/' \
		Makefile.in || die
	mv configure.in configure.ac || die
	sed -i -e 's/	#/#/' "${S}/nebu/scripting/Makefile.am" || die
	eapply_user
	eautoreconf
}

src_configure() {
	# warn/debug/profile just modify CFLAGS, they aren't
	# real options, so don't utilize USE flags here
	econf \
		--datadir=/usr/share/games \
		--datarootdir=/usr/share \
		--disable-warn \
		--disable-debug \
		--disable-profile
}

src_install() {
	default
	doicon "${DISTDIR}"/${PN}.png
	make_desktop_entry ${PN} GLtron
}
