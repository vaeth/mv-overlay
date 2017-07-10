# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit cmake-utils flag-o-matic python-any-r1

DESCRIPTION="Plugins for media-video/avidemux"
HOMEPAGE="http://fixounet.free.fr/avidemux"

# Multiple licenses because of all the bundled stuff.
LICENSE="GPL-1 GPL-2 MIT PSF-2 public-domain"
SLOT="2.6"
IUSE="aac aften a52 alsa amr dcaenc debug dts fdk fontconfig fribidi jack lame libsamplerate cpu_flags_x86_mmx nvenc opengl opus oss pulseaudio qt4 qt5 vorbis truetype twolame xv xvid x264 x265 vdpau vpx"
REQUIRED_USE="!amd64? ( !nvenc ) qt5? ( !qt4 )"

MY_PN="${PN/-plugins/}"
if [[ ${PV} == *9999* ]] ; then
	MY_P=$P
	KEYWORDS=""
	PROPERTIES="live"
	EGIT_REPO_URI="https://github.com/mean00/${MY_P}2"
	inherit git-r3
else
	MY_P="${MY_PN}_${PV}"
	SRC_URI="mirror://sourceforge/${MY_PN}/${MY_PN}/${PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

RDEPEND="
	~media-libs/avidemux-core-${PV}:${SLOT}[vdpau?]
	~media-video/avidemux-${PV}:${SLOT}[opengl?,qt4?,qt5?]
	>=dev-lang/spidermonkey-1.5-r2:0=
	dev-libs/libxml2:2
	media-libs/a52dec:0
	media-libs/libass:0=
	media-libs/libmad:0
	media-libs/libmp4v2:0
	media-libs/libpng:0=
	virtual/libiconv:0
	aac? (
		media-libs/faac:0
		media-libs/faad2:0
	)
	aften? ( media-libs/aften:0 )
	alsa? ( >=media-libs/alsa-lib-1.0.3b-r2:0 )
	amr? ( media-libs/opencore-amr:0 )
	dcaenc? ( media-sound/dcaenc:0 )
	dts? ( media-libs/libdca:0 )
	fdk? ( media-libs/fdk-aac:0 )
	fontconfig? ( media-libs/fontconfig:1.0 )
	fribidi? ( dev-libs/fribidi:0 )
	jack? (
		media-sound/jack-audio-connection-kit:0
		libsamplerate? ( media-libs/libsamplerate:0 )
	)
	lame? ( media-sound/lame:0 )
	nvenc? ( amd64? ( media-video/nvidia_video_sdk:0 ) )
	opus? ( media-libs/opus:0 )
	pulseaudio? ( media-sound/pulseaudio:0 )
	truetype? ( media-libs/freetype:2 )
	twolame? ( media-sound/twolame:0 )
	x264? ( media-libs/x264:0= )
	x265? ( media-libs/x265:0= )
	xv? (
		x11-libs/libX11:0
		x11-libs/libXext:0
		x11-libs/libXv:0
	)
	xvid? ( media-libs/xvid:0 )
	vorbis? ( media-libs/libvorbis:0 )
	vpx? ( media-libs/libvpx:0 )
"
DEPEND="${RDEPEND}
	oss? ( virtual/os-headers:0 )
	${PYTHON_DEPS}"

S="${WORKDIR}/${MY_P}"
PATCHES=( "${FILESDIR}"/${PN}-2.6.20-optional-pulse.patch )

src_setup() {
	CMAKE_MAKEFILE_GENERATOR=emake # ninja does not work, currently
}

src_prepare() {
	default
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

	processes="buildPluginsCommon:avidemux_plugins
		buildPluginsCLI:avidemux_plugins"
	if use qt4 || use qt5 ; then
		export QT_SELECT
		processes+=" buildPluginsQt4:avidemux_plugins"
	fi

	for process in ${processes} ; do
		local build="${process%%:*}"

		local mycmakeargs
		mycmakeargs=(
			-DAVIDEMUX_SOURCE_DIR="'${S}'"
			-DPLUGIN_UI=$(echo ${build/buildPlugins/} | tr '[:lower:]' '[:upper:]')
			-DFAAC="$(usex aac)"
			-DFAAD="$(usex aac)"
			-DALSA="$(usex alsa)"
			-DAFTEN="$(usex aften)"
			-DDCAENC="$(usex dcaenc)"
			-DFDK_AAC="$(usex fdk)"
			-DOPENCORE_AMRWB="$(usex amr)"
			-DOPENCORE_AMRNB="$(usex amr)"
			-DLIBDCA="$(usex dts)"
			-DFONTCONFIG="$(usex fontconfig)"
			-DJACK="$(usex jack)"
			-DLAME="$(usex lame)"
			-DNVENC="$(usex nvenc)"
			-DOPUS="$(usex opus)"
			-DOSS="$(usex oss)"
			-DPULSEAUDIOSIMPLE="$(usex pulseaudio)"
			-DQT4="$(usex qt4)"
			-DFREETYPE2="$(usex truetype)"
			-DTWOLAME="$(usex twolame)"
			-DX264="$(usex x264)"
			-DX265="$(usex x265)"
			-DXVIDEO="$(usex xv)"
			-DXVID="$(usex xvid)"
			-DVDPAU="$(usex vdpau)"
			-DVORBIS="$(usex vorbis)"
			-DLIBVORBIS="$(usex vorbis)"
			-DVPXDEC="$(usex vpx)"
			-DUSE_EXTERNAL_LIBA52=yes
			-DUSE_EXTERNAL_LIBASS=yes
			-DUSE_EXTERNAL_LIBMAD=yes
			-DUSE_EXTERNAL_LIBMP4V2=yes
		)
		if use qt5 ; then
			mycmakeargs+=( -DENABLE_QT5=True )
			QT_SELECT=5
			qt_ext=Qt5
			export qt_ext
		elif use qt4 ; then
			QT_SELECT=4
		fi

		! use debug || mycmakeargs+=(
			-DVERBOSE=1
			-DCMAKE_BUILD_TYPE=Debug
			-DADM_DEBUG=1
		)

		mkdir "${S}"/${build} || die "Can't create build folder."

		CMAKE_USE_DIR="${S}"/${process#*:} BUILD_DIR="${S}"/${build} cmake-utils_src_configure
	done
}

src_compile() {
	for process in ${processes} ; do
		BUILD_DIR="${S}/${process%%:*}" cmake-utils_src_compile
	done
}

src_install() {
	for process in ${processes} ; do
		# cmake-utils_src_install doesn't respect BUILD_DIR
		# and there sometimes is a preinstall phase present.
		pushd "${S}/${process%%:*}" > /dev/null || die
			grep '^preinstall/fast' Makefile && emake DESTDIR="${D}" preinstall/fast
			grep '^install/fast' Makefile && emake DESTDIR="${D}" install/fast
		popd > /dev/null || die
	done
}
