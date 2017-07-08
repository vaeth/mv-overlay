# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils flag-o-matic

DESCRIPTION="Core libraries for media-video/avidemux"
HOMEPAGE="http://fixounet.free.fr/avidemux"

# Multiple licenses because of all the bundled stuff.
LICENSE="GPL-1 GPL-2 MIT PSF-2 public-domain"
SLOT="2.6"
IUSE="debug nls nvenc sdl system-ffmpeg vaapi vdpau video_cards_fglrx xv"

if [[ ${PV} == *9999* ]] ; then
	MY_P=$P
	KEYWORDS=""
	PROPERTIES="live"
	EGIT_REPO_URI="https://github.com/mean00/${MY_P}2"
	inherit git-r3
else
	MY_PN="${PN/-core/}"
	MY_P="${MY_PN}_${PV}"
	SRC_URI="mirror://sourceforge/${MY_PN}/${MY_PN}/${PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

# Trying to use virtual; ffmpeg misses aac,cpudetection USE flags now though, are they needed?
DEPEND="
	!<media-video/avidemux-${PV}:${SLOT}
	dev-db/sqlite:3
	sdl? ( media-libs/libsdl:0 )
	system-ffmpeg? ( >=virtual/ffmpeg-9:0[mp3,theora] )
	xv? ( x11-libs/libXv:0 )
	vaapi? ( x11-libs/libva:0 )
	vdpau? ( x11-libs/libvdpau:0 )
	nvenc? ( amd64? ( media-video/nvidia_video_sdk:0 ) )
"
RDEPEND="
	$DEPEND
	nls? ( virtual/libintl:0 )
"
DEPEND="
	$DEPEND
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
	!system-ffmpeg? ( dev-lang/yasm[nls=] )
"

REQUIRED_USE="!amd64? ( !nvenc )"

S="${WORKDIR}/${MY_P}"
CMAKE_USE_DIR="${S}/${PN/-/_}"

DOCS=( AUTHORS README )

src_setup() {
	CMAKE_MAKEFILE_GENERATOR=emake # ninja does not work, currently
}

src_prepare() {
	cmake-utils_src_prepare

	if use system-ffmpeg ; then
		# Preparations to support the system ffmpeg. Currently fails because it depends on files the system ffmpeg doesn't install.
		local error="Failed to remove ffmpeg."

		rm -rf cmake/admFFmpeg* cmake/ffmpeg* avidemux_core/ffmpeg_package buildCore/ffmpeg || die "${error}"
		sed -i -e 's/include(admFFmpegUtil)//g' \
			-e '/registerFFmpeg/d' \
			avidemux/commonCmakeApplication.cmake || die "${error}"
		sed -i -e 's/include(admFFmpegBuild)//g' \
			avidemux_core/CMakeLists.txt || die "${error}"
	fi
}

src_configure() {
	if test-flags-CXX -std=c++14 ; then
		append-cxxflags -std=c++14
	elif test-flags-CXX -std=c++11 ; then
		append-cxxflags -std=c++11
	elif use qt4 || use qt5 ; then
		die "For qt support a compiler with c++11 support is needed"
	fi

	# Add lax vector typing for PowerPC.
	if use ppc || use ppc64 ; then
		append-cflags -flax-vector-conversions
	fi

	# See bug 432322.
	use x86 && replace-flags -O0 -O1

	# Filter problematic flags
	filter-flags -fwhole-program -flto

	local mycmakeargs
	mycmakeargs=(
		-DAVIDEMUX_SOURCE_DIR="'${S}'"
		-DGETTEXT="$(usex nls)"
		-DSDL="$(usex sdl)"
		-DLIBVA="$(usex vaapi)"
		-DVDPAU="$(usex vdpau)"
		-DXVBA="$(usex video_cards_fglrx)"
		-DXVIDEO="$(usex xv)"
		-DNVENC="$(usex nvenc)"
	)

	if use debug ; then
		mycmakeargs+=( -DVERBOSE=1 -DCMAKE_BUILD_TYPE=Debug -DADM_DEBUG=1 )
	fi

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile -j1
}

src_install() {
	cmake-utils_src_install -j1
}
