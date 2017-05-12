# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools flag-o-matic

DESCRIPTION="An extremely powerful ICCCM-compliant multiple virtual desktop window manager"
HOMEPAGE="http://www.fvwm.org/"
SRC_URI="ftp://ftp.fvwm.org/pub/fvwm/version-2/${P}.tar.bz2"

LICENSE="GPL-2 FVWM"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE="bidi debug doc gtk2-perl iconv netpbm nls perl png readline rplay stroke svg tk truetype +vanilla xinerama lock"

COMMON_DEPEND="
	sys-libs/zlib
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libxcb
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXpm
	x11-libs/libXrandr
	x11-libs/libXrender
	bidi? ( dev-libs/fribidi )
	iconv? ( virtual/libiconv )
	nls? ( virtual/libintl )
	png? ( media-libs/libpng:0= )
	readline? (
		sys-libs/ncurses:0=
		sys-libs/readline:0=
	)
	stroke? ( dev-libs/libstroke )
	svg? ( gnome-base/librsvg )
	truetype? (
		media-libs/fontconfig
		x11-libs/libXft
	)
	xinerama? (
		x11-proto/xineramaproto
		x11-libs/libXinerama
	)
"
RDEPEND="${COMMON_DEPEND}
	dev-lang/perl
	gtk2-perl? ( dev-perl/Gtk2 )
	perl? ( tk? (
			dev-lang/tk
			dev-perl/Tk
			>=dev-perl/X11-Protocol-0.56
		)
	)
	rplay? ( media-sound/rplay )
	lock? ( x11-misc/xlockmore )
	userland_GNU? ( sys-apps/debianutils )
	!x86-fbsd? ( netpbm? ( media-libs/netpbm ) )
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	doc? ( dev-libs/libxslt )
	x11-proto/xextproto
	x11-proto/xproto
"

src_prepare() {
	if ! use vanilla; then
		# Enables fast translucent menus; patch from fvwm-user mailing list.
		eapply -p0 "${FILESDIR}/${PN}-2.5.27-translucent-menus.diff"

		# Allow more mouse buttons, bug #411811
		eapply -p0 "${FILESDIR}/${PN}-2.6.5-mouse-buttons.patch"
	fi

	eapply -p0 "${FILESDIR}/${PN}-2.6.5-ar.patch" #474528
	eapply_user
	eautoreconf
}

src_configure() {
	local myconf="--libexecdir=/usr/$(get_libdir) --with-imagepath=/usr/include/X11/bitmaps:/usr/include/X11/pixmaps:/usr/share/icons/fvwm --enable-package-subdirs --without-gnome"

	# Non-upstream email where bugs should be sent; used in fvwm-bug.
	export FVWM_BUGADDR="desktop-wm@gentoo.org"

	# Recommended by upstream.
	append-flags -fno-strict-aliasing

	# Signed chars are required.
	use ppc && append-flags -fsigned-char

	myconf="${myconf} --disable-gtk"

	use readline && myconf="${myconf} --without-termcap-library"

	econf ${myconf} \
		$(use_enable bidi) \
		$(use_enable debug debug-msgs) \
		$(use_enable debug command-log) \
		$(use_enable doc htmldoc) \
		$(use_enable iconv) \
		$(use_enable nls) \
		$(use_enable perl perllib) \
		$(use_with png png-library) \
		$(use_with readline readline-library) \
		$(use_with rplay rplay-library) \
		$(use_with stroke stroke-library) \
		$(use_enable svg rsvg) \
		$(use_enable truetype xft) \
		$(use_enable xinerama) \
		--docdir="/usr/share/doc/${P}"
}

src_install() {
	emake DESTDIR="${ED}" docdir="/usr/share/doc/${P}" install

	# These are always removed, because gentoo doesn't have anymore
	# a dev-perl/gtk-perl package, so, these modules are pointless.
	rm -f -- "${ED}/usr/share/fvwm/perllib/FVWM/Module/Gtk.pm" || die
	find "${ED}" -name '*FvwmGtkDebug*' -exec rm -f '{}' \; 2>/dev/null || die

	if ! use lock; then
		find "${ED}" -name '*fvwm-menu-xlock' -exec rm -f '{}' \; 2>/dev/null || die
	fi

	if use perl; then
		if ! use tk; then
			rm -f -- "${ED}/usr/share/fvwm/perllib/FVWM/Module/Tk.pm" || die
			if ! use gtk2-perl; then # no tk and no gtk2 bindings
				rm -f -- "${ED}/usr/share/fvwm/perllib/FVWM/Module/Toolkit.pm" || die
				find "${ED}/usr/share/fvwm/perllib" -depth -type d -exec rmdir '{}' \; \
					2>/dev/null || die
			fi
		fi

		# Now, the Gtk2.pm file, it will require dev-perl/Gtk2
		# so it implies gtk2 as well. That's why we need another use flag.
		if ! use gtk2-perl; then
			rm -f -- "${ED}/usr/share/fvwm/perllib/FVWM/Module/Gtk2.pm" || die
		fi
	else
		# Completely wipe it if ! use perl
		rm -rf -- "${ED}/usr/bin/fvwm-perllib" \
			"${ED}/usr/share/man/man1/fvwm-perllib.1" || die
	fi

	# Utility for testing FVWM behaviour by creating a simple window with
	# configurable hints.
	if use debug; then
		dobin "${S}/tests/hints/hints_test"
		newdoc "${S}/tests/hints/README" README.hints
	fi

	dodir /etc/X11/Sessions
	echo "/usr/bin/fvwm" > "${ED}/etc/X11/Sessions/${PN}" || die
	fperms a+x /etc/X11/Sessions/${PN} || die

	dodoc AUTHORS ChangeLog NEWS README \
		docs/{ANNOUNCE,BUGS,COMMANDS,CONVENTIONS} \
		docs/{DEVELOPERS,error_codes,FAQ,TODO,fvwm.lsm}

	# README file for translucent menus patch.
	if ! use vanilla; then
		dodoc "${FILESDIR}"/README.translucency
		ewarn "You are using a patched build, so, please, don't"
		ewarn "report bugs at the fvwm-workers list unless you are"
		ewarn "also able to reproduce them with a vanilla build (USE=vanilla)."
	fi

	if ! use iconv; then
		ewarn "If you have window title encoding issues, remerge"
		ewarn "${CATEGORY}/${PN} with USE=iconv and restart FVWM."
	fi
}
