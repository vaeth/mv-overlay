# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-info toolchain-funcs xdg-utils

SRC_URI="https://github.com/phillipberndt/pqiv/archive/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc x86"

DESCRIPTION="powerful GTK based command-line image viewer with a minimal UI"
HOMEPAGE="https://github.com/phillipberndt/pqiv http://www.pberndt.com/Programme/Linux/pqiv/"

LICENSE="GPL-2"
SLOT="0"
IUSE="archive ffmpeg gtk2 imagemagick kernel_linux pdf postscript webp"

RDEPEND="
	>=dev-libs/glib-2.32:2
	>=x11-libs/cairo-1.6
	gtk2? ( x11-libs/gtk+:2 )
	!gtk2? ( x11-libs/gtk+:3 )
	archive? ( app-arch/libarchive:0= )
	ffmpeg? ( media-video/ffmpeg:0= )
	imagemagick? ( media-gfx/imagemagick:0= )
	pdf? ( app-text/poppler:0= )
	postscript? ( app-text/libspectre:0= )
	webp? ( media-libs/libwebp:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

doecho() {
	echo "$@"
	"$@" || die
}

pkg_setup() {
	if use kernel_linux; then
		CONFIG_CHECK="~INOTIFY_USER"
		linux-info_pkg_setup
	fi
}

src_configure() {
	local backends="gdkpixbuf" gtkver=3
	! use gtk2 || gtkver=2
	use archive && backends+=",archive,archive_cbx"
	use ffmpeg && backends+=",libav"
	use imagemagick && backends+=",wand"
	use pdf && backends+=",poppler"
	use postscript && backends+=",spectre"
	use webp && backends+=",webp"

	doecho ./configure \
		--gtk-version=${gtkver} \
		--backends-build=shared \
		--backends=${backends} \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--destdir="${ED}"
}

src_compile() {
	tc-export CC
	emake VERBOSE=1 CFLAGS="${CFLAGS}"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
