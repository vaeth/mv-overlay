# Copyright 1999-2019 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"

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
	fi

	for process in ${processes} ; do
		CMAKE_USE_DIR="${S}"/${process#*:} cmake-utils_src_prepare
	done
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

	# Fix underlinking with gold
	sed -i -e 's/{QT_QTGUI_LIBRARY}/{QT_QTGUI_LIBRARY} -lXext/' \
		avidemux/common/ADM_render/CMakeLists.txt || die
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

	if [[ -f "${ED}"/usr/bin/avidemux3_cli ]] ; then
		fperms +x /usr/bin/avidemux3_cli
	fi

	if [[ -f "${ED}"/usr/bin/avidemux3_jobs ]] ; then
		fperms +x /usr/bin/avidemux3_jobs
	fi

	if [[ -f "${ED}"/usr/bin/avidemux3_qt5 ]] ; then
		fperms +x /usr/bin/avidemux3_qt5
	fi

	if [[ -f "${ED}"/usr/bin/avidemux3_jobs_qt5 ]] ; then
		fperms +x /usr/bin/avidemux3_jobs_qt5
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
