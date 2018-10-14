# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools desktop

DATA_PV="1.0.0"
DESCRIPTION="Underwater puzzle game - find a safe way out"
HOMEPAGE="http://fillets.sourceforge.net/"
SRC_URI="mirror://sourceforge/fillets/fillets-ng-${PV}.tar.gz
	mirror://sourceforge/fillets/fillets-ng-data-${DATA_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="lua-slotted"

RDEPEND="
	>=media-libs/libsdl-1.2[sound,video]
	>=media-libs/sdl-mixer-1.2.5[vorbis]
	>=media-libs/sdl-image-1.2.2[png]
	media-libs/smpeg
	x11-libs/libX11
	media-libs/sdl-ttf
	dev-libs/fribidi
	lua-slotted? ( dev-lang/lua:5.1= )
	!lua-slotted? ( dev-lang/lua:0= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/fillets-ng-${PV}"

src_prepare() {
	default
	#.mod was renamed to .fmod in lua 5.1.3 - bug #223271
	sed -i \
		-e 's/\.mod(/.fmod(/' \
		$(grep -rl "\.mod\>" "${WORKDIR}"/fillets-ng-data-${DATA_PV}) \
		|| die "sed failed"
	rm -f missing
	mv configure.in configure.ac || die
	if use lua-slotted; then
		sed -i \
			-e 's/LUAPFX=/LUAPFX=1/g' \
			-e "s'-I.LUAPFX'-I${EROOT}/usr/include/lua5.1'" \
			-e "s'-L.LUAPFX[^\"]*'-llua5.1'" \
			configure.ac || die
	fi
	eautoreconf
}

src_configure() {
	econf --datadir="/usr/share/${PN}"
}

src_install() {
	default
	insinto "/usr/share/${PN}"
	cd "${WORKDIR}"/fillets-ng-data-${DATA_PV} || die
	rm -f COPYING
	einstalldocs
	doins -r *
	newicon images/icon.png ${PN}.png
	make_desktop_entry fillets "Fish Fillets NG"
}
