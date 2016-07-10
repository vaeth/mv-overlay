# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools gnome2

DESCRIPTION="Genius Mathematics Tool and the GEL Language"
HOMEPAGE="http://www.jirka.org/genius.html"
SRC_URI="
	mirror://gnome/sources/${PN}/1.0/${P}.tar.xz
	doc? ( http://www.jirka.org/${PN}-reference.pdf )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc gnome nls"

RDEPEND="
	dev-libs/glib:2
	dev-libs/gmp:0=
	dev-libs/mpfr:0
	dev-libs/popt
	sys-libs/ncurses:0=
	sys-libs/readline:0=
	gnome? (
		app-text/scrollkeeper
		app-text/gnome-doc-utils
		x11-libs/gtk+:2
		gnome-base/libgnome
		gnome-base/libgnomeui
		gnome-base/libglade:2.0
		x11-libs/gtksourceview:2.0
		x11-libs/vte:0 )"
DEPEND="${RDEPEND}
	dev-util/intltool
	|| ( sys-devel/bison dev-util/yacc )
	sys-devel/flex
	nls? ( sys-devel/gettext )"

DOCS=(AUTHORS ChangeLog NEWS README TODO)

src_prepare() {
	eapply_user
	if ! use gnome
	then	sed -e "/GNOME_DOC_INIT/d" \
				configure.in >configure.ac
			rm configure.in
			sed -i \
				-e '/gnome-doc-utils\.make/d' \
				help/Makefile.am
			eautoreconf
	fi
}

src_configure() {
	gnome2_src_configure $(use_enable gnome) $(use_enable nls) \
		--disable-update-mimedb --disable-scrollkeeper \
		--disable-extra-gcc-optimization
}

src_install() {
	use doc && dodoc "${DISTDIR}/${PN}-reference.pdf"
	gnome2_src_install
}
