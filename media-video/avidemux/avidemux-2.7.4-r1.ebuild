# Copyright 1999-2019 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

if [[ ${PV} == *9999* ]] ; then
	MY_P="${P}"
	EGIT_REPO_URI="https://github.com/mean00/avidemux2.git"
	inherit git-r3
else
	MY_P="${PN}_${PV}"
	SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi
inherit cmake-utils qmake-utils xdg-utils

DESCRIPTION="Video editor designed for simple cutting, filtering and encoding tasks"
HOMEPAGE="http://fixounet.free.fr/avidemux"

# Multiple licenses because of all the bundled stuff.
LICENSE="GPL-1 GPL-2 MIT PSF-2 public-domain"
SLOT="2.7"
IUSE="debug nls nvenc opengl qt5 sdl vaapi vdpau xv"

DEPEND="
	~media-libs/avidemux-core-${PV}:${SLOT}[nls?,sdl?,vaapi?,vdpau?,xv?,nvenc?]
	nvenc? ( amd64? ( media-video/nvidia_video_sdk:0 ) )
	opengl? ( virtual/opengl:0 )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
	)
	vaapi? ( x11-libs/libva:0= )
"
BDEPEND="
	qt5? ( dev-qt/linguist-tools:5 )
"
RDEPEND="${DEPEND}
	nls? ( virtual/libintl:0 )
	!<media-video/avidemux-${PV}
"
PDEPEND="~media-libs/avidemux-plugins-${PV}:${SLOT}[opengl?,qt5?]"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	processes="buildCli:avidemux/cli"
	if use qt5 ; then
		processes+=" buildQt4:avidemux/qt4"
		# Fix icon name -> avidemux-2.7
		sed -i -e "/^Icon/ s:${PN}\.png:${PN}-${SLOT}:" appImage/${PN}.desktop || \
			die "Icon name fix failed."

		# The desktop file is broken. It uses avidemux3_portable instead of avidemux3_qt5
		sed -i -re '/^Exec/ s:(avidemux3_)portable:\1qt5:' appImage/${PN}.desktop || \
			die "Desktop file fix failed."

		# QA warnings: missing trailing ';' and 'Application' is deprecated.
		sed -i -e 's/Application;AudioVideo/AudioVideo;/g' appImage/${PN}.desktop || \
			die "Desktop file fix failed."

		# Now rename the desktop file to not collide with 2.6.
		mv appImage/${PN}.desktop ${PN}-${SLOT}.desktop || die "Collision rename failed."
	fi

	for process in ${processes} ; do
		CMAKE_USE_DIR="${S}"/${process#*:} cmake-utils_src_prepare
	done

	# Remove "Build Option" dialog because it doesn't reflect
	# what the GUI can or has been built with. (Bug #463628)
	sed -i -e '/Build Option/d' avidemux/common/ADM_commonUI/myOwnMenu.h || \
		die "Couldn't remove \"Build Option\" dialog."

	# Fix underlinking with gold
	sed -i -e 's/{QT_QTGUI_LIBRARY}/{QT_QTGUI_LIBRARY} -lXext/' \
		avidemux/common/ADM_render/CMakeLists.txt || die
}

src_configure() {
	# Add lax vector typing for PowerPC.
	if use ppc || use ppc64 ; then
		append-cflags -flax-vector-conversions
	fi

	# See bug 432322.
	use x86 && replace-flags -O0 -O1

	local mycmakeargs=(
		-DGETTEXT="$(usex nls)"
		-DSDL="$(usex sdl)"
		-DLibVA="$(usex vaapi)"
		-DOPENGL="$(usex opengl)"
		-DVDPAU="$(usex vdpau)"
		-DXVIDEO="$(usex xv)"
	)

	if use qt5 ; then
		mycmakeargs+=(
			-DENABLE_QT5="$(usex qt5)"
			-DLRELEASE_EXECUTABLE="$(qt5_get_bindir)/lrelease"
		)
	fi

	if use debug ; then
		mycmakeargs+=( -DVERBOSE=1 -DADM_DEBUG=1 )
	fi

	for process in ${processes} ; do
		local build="${WORKDIR}/${P}_build/${process%%:*}"
		CMAKE_USE_DIR="${S}"/${process#*:} BUILD_DIR="${build}" cmake-utils_src_configure
	done
}

src_compile() {
	for process in ${processes} ; do
		local build="${WORKDIR}/${P}_build/${process%%:*}"
		BUILD_DIR="${build}" cmake-utils_src_compile
	done
}

src_test() {
	for process in ${processes} ; do
		local build="${WORKDIR}/${P}_build/${process%%:*}"
		BUILD_DIR="${build}" cmake-utils_src_test
	done
}

src_install() {
	for process in ${processes} ; do
		local build="${WORKDIR}/${P}_build/${process%%:*}"
		BUILD_DIR="${build}" cmake-utils_src_install
	done

	if use qt5; then
		cd "${S}" || die "Can't enter source folder"
		newicon ${PN}_icon.png ${PN}-${SLOT}.png
		domenu ${PN}-${SLOT}.desktop
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
