# Copyright 2016-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit desktop user
RESTRICT="mirror"

DESCRIPTION="simple game similar to the classical game Marble Madness"
HOMEPAGE="http://trackballs.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://sourceforge/${PN}/${PN}-music-1.4.tar.bz2"

LICENSE="GPL-2 FML-1"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="nls"

RDEPEND="virtual/opengl
	virtual/glu
	media-libs/libsdl[sound,joystick,video]
	>=dev-scheme/guile-1.8:12[deprecated]
	media-libs/sdl-mixer
	media-libs/sdl-image
	media-libs/sdl-ttf
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}"
BDEPEND="nls? ( sys-devel/gettext )"

pkg_setup(){
	enewgroup gamestat 36
}

src_prepare() {
	sed -i \
		-e 's/icons //' \
		-e 's/games/gamestat/' \
		share/Makefile.in \
		|| die
	sed -i \
		-e '/^localedir/s:=.*:=/usr/share/locale:' \
		src/Makefile.in \
		po/Makefile.in.in \
		|| die
	# Fix _FORTIFY_SOURCE buffer overflow due to wrong sizeof
	sed -i \
		-e 's/\(snprintf(\(name\),sizeof\)(str)/\1(\2)/' \
		src/enterHighScoreMode.cc || die
	# Fix -Wformat-security warning due to non-literal with no format arguments
	sed -i \
		-e 's/\(snprintf(levelname,sizeof(levelname),\)\(name)\)/\1 "%s", \2/' \
		-e 's/\(snprintf(Settings::settings->specialLevel,sizeof(Settings::settings->specialLevel),\)\(levelname)\)/\1 "%s", \2/' \
		src/editMode.cc || die
	sed -i \
		-e 's/\(snprintf(\(textureName\),\)63\(,textureNames\[i\])\)/\1 sizeof(\2), "%s"\3/' \
		src/map.cc || die
	eapply "${FILESDIR}"/${P}-warning.patch
	default
}

src_configure() {
	econf \
		--datadir=/usr/share/games \
		--datarootdir=/usr/share \
		--disable-dependency-tracking \
		--with-highscores=/var/games/${PN}.score \
		$(use_enable nls)
}

src_install() {
	make DESTDIR="${D}" install
	insinto /usr/share/games/${PN}/music
	doins "${WORKDIR}"/trackballs-music/*.ogg
	newicon share/icons/${PN}-64x64.png ${PN}.png
	make_desktop_entry ${PN} Trackballs
	dodoc AUTHORS ChangeLog FAQ NEWS README TODO
	fowners root:gamestat /usr/bin/${PN}
	fperms 2755 /usr/bin/${PN}
}
