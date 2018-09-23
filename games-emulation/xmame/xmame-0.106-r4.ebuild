# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic toolchain-funcs
RESTRICT="mirror"

TARGET="${PN}"

DESCRIPTION="Multiple Arcade Machine Emulator for X11"
HOMEPAGE="http://x.mame.net/"
SRC_URI="http://gentoo.osuosl.org/distfiles/xmame-${PV}.tar.bz2"

LICENSE="XMAME"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc sparc x86"
IUSE="alsa bundled-libs cpu_flags_x86_mmx dga ggi joystick lirc net opengl sdl svga X xinerama xv"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	dga? (
		x11-libs/libXxf86dga
		x11-libs/libXxf86vm )
	!bundled-libs? ( dev-libs/expat )
	ggi? ( media-libs/libggi )
	lirc? ( app-misc/lirc )
	opengl? (
		virtual/opengl
		virtual/glu )
	sdl? ( >=media-libs/libsdl-1.2.0 )
	svga? ( media-libs/svgalib )
	xinerama? ( x11-libs/libXinerama )
	xv? ( x11-libs/libXv )
	X? ( x11-libs/libXext )"
DEPEND="${RDEPEND}"
BDEPEND="x86? ( dev-lang/nasm )
	x11-base/xorg-proto"
# Icc sucks. bug #41342
#	icc? ( dev-lang/icc )

S=${WORKDIR}/xmame-${PV}
PATCHES=( "${FILESDIR}/fix-zn1-looping-sound.patch" )

toggle_feature() {
	if use $1 ; then
		sed -i \
			-e "/$2.*=/s:#::" Makefile \
			|| die "sed Makefile ($1 / $2) failed"
	fi
}

toggle_feature2() {
	use $1 && toggle_feature $2 $3
}

src_prepare() {
	local mycpu

	case ${ARCH} in
		x86)	mycpu="i386";;
		ia64)	mycpu="ia64";;
		amd64)	mycpu="amd64";;
		ppc)	mycpu="risc";;
		sparc)	mycpu="risc";;
		hppa)	mycpu="risc";;
		alpha)	mycpu="alpha";;
		mips)	mycpu="mips";;
	esac

	sed -i \
		-e "/^PREFIX/s:=.*:=/usr:" \
		-e "/^MY_CPU/s:i386:${mycpu}:" \
		-e "/^MANDIR/s:man/man:share/man/man:" \
		-e "/^TARGET/s:mame:${TARGET:1}:" \
		-e "/^INSTALL_GROUP/s:bin:root:" \
		-e "/^CFLAGS =/d" \
		-e 's/-s,//' \
		-e 's/-Wl,-s//' \
		-e "/\bCFLAGS +=/d" \
		Makefile \
		|| die "sed Makefile failed"

	if use ppc ; then
		sed -i \
			-e '/LD.*--relax/s:^# ::' Makefile \
			|| die "sed Makefile (ppc/LD) failed"
	fi

	if use cpu_flags_x86_mmx ; then
		cat >> src/unix/effect_asm.asm <<EOF
		%ifidn __OUTPUT_FORMAT__,elf
		section .note.GNU-stack noalloc noexec nowrite progbits
		%endif
EOF
	fi

	toggle_feature x86 X86_MIPS3_DRC
	toggle_feature2 x86 cpu_flags_x86_mmx EFFECT_MMX_ASM
	toggle_feature joystick JOY_STANDARD
	toggle_feature2 joystick X XINPUT_DEVICES
	use net && ewarn "Network support is currently (${PV}) broken :("
	#toggle_feature net XMAME_NET # Broken
	#toggle_feature esd SOUND_ESOUND # No esound in portage anymore
	toggle_feature alsa SOUND_ALSA
	#toggle_feature arts SOUND_ARTS # Deprecated
	toggle_feature dga X11_DGA
	toggle_feature xv X11_XV
	# if we don't have expat on the system, use the internal one
	toggle_feature bundled-libs BUILD_EXPAT
	toggle_feature opengl X11_OPENGL
	toggle_feature lirc LIRC
	toggle_feature xinerama X11_XINERAMA

	case ${ARCH} in
		x86|ia64|amd64)
			append-flags -Wno-unused -fomit-frame-pointer -fstrict-aliasing -fstrength-reduce
			use amd64 || append-flags -ffast-math #54270
			[[ $(gcc-major-version) -ge 3 ]] \
				&& append-flags -falign-functions=2 -falign-jumps=2 -falign-loops=2 \
				|| append-flags -malign-functions=2 -malign-jumps=2 -malign-loops=2
			;;
		ppc)
			append-flags -Wno-unused -funroll-loops -fstrength-reduce -fomit-frame-pointer -ffast-math -fsigned-char
			;;
		hppa)
			append-flags -ffunction-sections
			;;
	esac

	sed -i \
		-e "s:[Xx]mame:${TARGET}:g" \
		doc/*.6 \
		|| die "sed man pages failed"
	# no, we don't want to install setuid (bug #81693)
	sed -i \
		-e 's/^doinstallsuid/notforus/' \
		-e 's/doinstallsuid/doinstall/' \
		-e '/^QUIET/s:^:#:' src/unix/unix.mak \
		|| die "sed src/unix/unix.mak failed"
	default
}

src_compile() {
	local disp=0
	if use sdl ; then
		emake -j1 DISPLAY_METHOD=SDL \
			CC=$(tc-getCC) \
			LD=$(tc-getCC)
		disp=1
	fi
	if use svga ; then
		emake -j1 DISPLAY_METHOD=svgalib \
			CC=$(tc-getCC) \
			LD=$(tc-getCC)
		disp=1
	fi
	if use ggi ; then
		#emake -j1 DISPLAY_METHOD=ggi
		#disp=1
		ewarn "GGI support is currently (${PV}) broken :("
	fi
	if  [[ ${disp} -eq 0 ]] || use opengl || use X || use dga || use xv ; then
		emake -j1 DISPLAY_METHOD=x11 \
			CC=$(tc-getCC) \
			LD=$(tc-getCC)
	fi
}

src_install() {
	local disp=0 f utils="chdman imgtool dat2html romcmp xml2info"

	if use sdl ; then
		make DISPLAY_METHOD=SDL PREFIX="${ED}/usr" install \
			|| die "install failed (sdl)"
		disp=1
	fi
	if use svga ; then
		make DISPLAY_METHOD=svgalib PREFIX="${ED}/usr" install \
			|| die "install failed (svga)"
		disp=1
	fi
	if use ggi ; then
		#make DISPLAY_METHOD=ggi install || die "install failed (ggi)"
		#disp=1
		ewarn "GGI support is currently (${PV}) broken :("
	fi
	if [[ ${disp} -eq 0 ]] || use opengl || use X || use dga || use xv ; then
		make DISPLAY_METHOD=x11 PREFIX="${ED}/usr" install \
			|| die "install failed (x11)"
	fi
	exeinto "/usr/$(get_libdir)/${PN}"
	for f in $utils
	do
		if [[ -f "${ED}"/usr/bin/$f ]] ; then
			doexe $f
			rm -f "${ED}"/usr/bin/$f 2>/dev/null
		fi
	done

	insinto "/usr/share/${PN}"
	doins -r ctrlr
	dodoc doc/{changes.*,*.txt,mame/*,${TARGET}rc.dist} README todo
	docinto html
	dodoc -r doc/img doc/mess doc/*.html doc/*.css

	# default to sdl since the client is a bit more featureful
	if use sdl ; then
		dosym "${TARGET}.SDL" "/usr/bin/${TARGET}"
	elif [[ ${disp} -eq 0 ]] || use opengl || use X || use dga || use xv ; then
		dosym "${TARGET}.x11" "/usr/bin/${TARGET}"
	elif use svga ; then
		dosym ${TARGET}.svgalib "/usr/bin/${TARGET}"
	#elif use ggi ; then
		#dosym ${TARGET}.ggi "/usr/bin/${TARGET}"
	fi
}

pkg_postinst() {
	elog "Your available MAME binaries are: ${TARGET}"
	if use opengl || use X || use dga || use xv ; then
		elog " ${TARGET}.x11"
	fi
	use sdl    && elog " ${TARGET}.SDL"
	#use ggi    && elog " ${TARGET}.ggi"
	use svga   && elog " ${TARGET}.svgalib"

	elog "Helper utilities are located in /usr/$(get_libdir)/${PN}."
}
