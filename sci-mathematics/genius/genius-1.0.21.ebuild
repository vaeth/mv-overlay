# Copyright 1999-2019 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"

inherit autotools gnome2

DESCRIPTION="Genius Mathematics Tool and the GEL Language"
HOMEPAGE="http://www.jirka.org/genius.html"
SRC_URI="${SRC_URI}
	doc? ( http://www.jirka.org/${PN}-reference.pdf )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc gnome nls"

RDEPEND="
	dev-libs/glib:2
	dev-libs/gmp:0=
	dev-libs/mpfr:0=
	dev-libs/popt
	sys-libs/ncurses:0=
	sys-libs/readline:0=
	gnome? (
		x11-libs/gtk+:2
		gnome-base/libgnome
		gnome-base/libgnomeui
		gnome-base/libglade:2.0
		x11-libs/gtksourceview:2.0
		x11-libs/vte:0 )
"
DEPEND="${RDEPEND}
	gnome? (
		app-text/rarian
		dev-util/gtk-update-icon-cache
		app-text/gnome-doc-utils
	)
	dev-util/intltool
	|| ( sys-devel/bison dev-util/yacc )
	sys-devel/flex
	nls? ( sys-devel/gettext )
"

src_prepare() {
	default
	if ! use gnome
	then	sed \
				-e "s/AC_PATH_PROG.\(SCROLLKEEPER_CONFIG\).*/\1=true/" \
				-e "s/AC_PATH_PROG.\(GTK_UPDATE_ICON_CACHE\).*/\1=true/" \
				configure.in >configure.ac
			sed -i \
				-e '/gnome-doc-utils\.make/d' \
				help/Makefile.am
			rm configure.in
			eautoreconf
	fi
}

src_configure() {
	gnome2_src_configure \
		$(use_enable gnome) \
		$(use_enable nls) \
		$(usex gnome '' --disable-scrollkeeper) \
		$(usex gnome '' --disable-update-mimedb) \
		--disable-extra-gcc-optimization \
		--disable-static
}

src_install() {
	use doc && DOCS+=" ${DISTDIR}/${PN}-reference.pdf"
	gnome2_src_install
}
