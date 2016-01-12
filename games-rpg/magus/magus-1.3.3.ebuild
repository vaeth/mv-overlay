# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit autotools eutils flag-o-matic
RESTRICT="mirror"

FETCH_RESTRICT=false
LIVE_VERSION=false
case ${PV} in
9999*)
	LIVE_VERSION=:;;
1.3.3*)
	FETCH_RESTRICT=:;;
esac

${LIVE_VERSION} && inherit monotone

DESCRIPTION="A character generator for the popular German role playing game Midgard"
HOMEPAGE="http://sourceforge.net/projects/midgard.berlios/"
SRC_URI="mirror://sourceforge/midgard.berlios/${P}.tar.bz2"
KEYWORDS="~amd64 ~x86"
if ${LIVE_VERSION}
then	PROPERTIES="live"
	SRC_URI=""
	EMTN_REPO_URI="petig-baender.dyndns.org"
	KEYWORDS=""
elif ${FETCH_RESTRICT}
then	SRC_URI="ftp://ftp.berlios.de/pub/midgard/Source/${P}.tar.bz2"
# Unfortunately, the URL is down forever:
# You can only use it, if you already downloaded the tarball earlier
	RESTRICT="${RESTRICT} fetch"
fi
LICENSE="GPL-2"
SLOT="0"
IUSE="+acroread imagemagick konqueror multilib pngcrush postgres seamonkey"
REQUIRED_USE="amd64? ( acroread? ( multilib ) )"

DEPENDCOMMON="dev-libs/libsigc++:2
	dev-cpp/gtkmm:2.4
	virtual/latex-base
	postgres? ( dev-db/postgresql:= )
	!postgres? ( dev-db/sqlite:3 )
	|| ( media-libs/netpbm media-gfx/graphicsmagick media-gfx/imagemagick )"

DEPEND="${DEPENDCOMMON}
	sys-devel/gettext
	pngcrush? ( media-gfx/pngcrush )
	imagemagick? ( || ( media-gfx/graphicsmagick[imagemagick] media-gfx/imagemagick ) )"

RDEPEND="${DEPENDCOMMON}
	seamonkey? ( www-client/seamonkey )
	!seamonkey? (
		konqueror? ( kde-apps/konqueror )
		!konqueror? (
			|| ( www-client/firefox www-client/firefox-bin )
		)
	)
	acroread? (
		!amd64? ( app-text/acroread )
		amd64? ( multilib? ( app-text/acroread ) )
	)
	virtual/libintl"

if ${LIVE_VERSION}
then
src_unpack() {
	monotone_fetch
	monotone_co "" "manuproc.berlios.de/ManuProC_Base"
	monotone_co "" "manuproc.berlios.de/GtkmmAddons"
	monotone_co "" "manuproc.berlios.de/ManuProC_Widgets"
	monotone_co "" "midgard.berlios.de/midgard"
	monotone_finish
}
fi

src_cp() {
	einfo "cp ${1} ${2}"
	test -f "${1}" || {
		ewarn "File ${1} does not exist"
		return 0
	}
	if ! test -e "${2}" || diff -q -- "${1}" "${2}" >/dev/null 2>&1
	then	ewarn "cp ${1} ${2} appears no longer necessary"
		return 0
	fi
	cp -- "${1}" "${2}"
}

src_sed() {
	local short file ori ignore remove grep opt
	ignore=false
	remove=false
	grep=''
	OPTIND=1
	while getopts 'fig:' opt
	do	case ${opt} in
		f)	remove=:;;
		i)	ignore=:;;
		g)	grep=${OPTARG};;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	short=${1}
	file="${S}/${short}"
	ori="${file}.ori"
	test -e "${ori}" && ${ignore} && ori="${file}.ori-1" && remove=:
	test -e "${ori}" && die "File ${ori} already exists"
	if ! test -e "${file}"
	then	die "Expected file ${short} does not exist"
	fi
	einfo "Patching ${short}"
	[ -n "${grep}" ] && grep -q -- "${grep}" "${file}" \
		&& ewarn "Redundant patching of ${short}"
	mv -- "${file}" "${ori}"
	shift
	sed "${@}" -- "${ori}" >"${file}"
	! ${ignore} && cmp -s -- "${ori}" "${file}" \
			&& ewarn "Unneeded patching of ${short}"
	${remove} && rm -- "${ori}"
	return 0
}

set_browser() {
	local i browser
	browser=
	for i in seamonkey konqueror
	do	use "${i}" || continue
		if [ -n "${browser}" ]
		then	ewarn "USE=${i} is overridden by USE=${browser}"
		else	browser=${i}
		fi
	done
	einfo
	if [ -z "${browser}" ]
	then	browser="firefox"
		einfo "Patching for default browser ${browser}:"
	elif [ "${browser}" = "mozilla" ]
	then	einfo "Keeping upstream's default browser (mozilla)"
			einfo
			return
	else	einfo "USE=${browser} overrides default browser firefox:"
	fi
	einfo
	src_sed midgard/docs/BMod_Op.html -e "s#mozilla#${browser}#"
	src_sed midgard/libmagus/Magus_Optionen.cc -e "s#mozilla#${browser}#"
	src_sed midgard/midgard.glade -e "s#mozilla#${browser}#"
	src_sed midgard/src/table_optionen_glade.cc -e "s#mozilla#${browser}#"
}

src_patch() {
	einfo
	einfo "Various patches:"
	einfo
	grep "saebel.png" midgard/src/Makefile.am && \
		ewarn "Unneeded patching of midgard/src/Makefile.am"
	src_sed midgard/src/Makefile.am \
		-e 's/drache.png/Money-gray.png saebel.png drache.png/'
	src_sed ManuProC_Widgets/configure.in \
		-e 's/^[[:space:]]*AM_GNU_GETTEXT_VERSION/AM_GNU_GETTEXT_VERSION/'
	src_sed -g 'AM_GNU_GETTEXT_VERSION' ManuProC_Base/configure.in \
		-e '/AC_SUBST(GETTEXT_PACKAGE)/iAM_GNU_GETTEXT_VERSION([0.17])'
#	src_cp ManuProC_Base/macros/petig.m4 ManuProC_Widgets/macros/petig.m4
	src_sed midgard/src/table_lernschema.cc \
		-e '/case .*:$/{n;s/^[[:space:]]*\}/break;}/}'
	find . -name configure.in -exec sh -c 'for i
	do	mv -- "${i}" "${i%in}ac"
	done' sh '{}' +
}

my_cd() {
	cd -- "${S}/${1}" >/dev/null || die "cd ${1} failed"
}

my_autoreconf() {
	my_cd "${1}"
	export AT_M4DIR
	test -d macros && AT_M4DIR="macros" || AT_M4DIR=""
	eautoreconf
}

src_prepare() {
	local i
	src_patch
	eapply_user
	set_browser
	einfo
	einfo "Calling eautoreconf for all subprojects:"
	einfo
	for i in "${S}"/*
	do	my_autoreconf "${i##*/}"
	done
}

my_conf() {
	einfo
	einfo "configuring ${1}"
	einfo
	my_cd "${1}"
	shift
	if [ -z "${COMMON_CONF}" ]
	then	COMMON_CONF="$(use_enable !postgres sqlite)"
		COMMON_CONF="${COMMON_CONF} $(use_with postgres postgresdir /usr)"
		COMMON_CONF="${COMMON_CONF} --disable-static"
	fi
	econf ${COMMON_CONF} "${@}"
}

my_make() {
	einfo
	einfo "making ${*}"
	einfo
	my_cd "${1}"
	emake || die "emake in ${1} failed"
}

my_confmake() {
	# It is unfortunate that we must build here,
	# but some ./configure's require make in other directories_
	my_make "GtkmmAddons" "(needed for configuring ManuProC_Widget and midgard)"
	my_make "ManuProC_Base" "(needed for configuring ManuProC_Widget and midgard)"
	my_conf "ManuProC_Widgets"
	my_make "ManuProC_Widgets" "(needed for configuring midgard)"
	my_conf "midgard"
}

src_configure() {
	filter-flags \
		-pie \
		-fPIE \
		-flto \
		-fwhole-program \
		-fuse-linker-plugin \
		-fvisibility-inlines-hidden
	my_conf "ManuProC_Base"
	my_conf "GtkmmAddons"
	my_confmake
}

src_compile() {
	my_make "midgard"
}

my_install() {
	my_cd "${1}"
	emake DESTDIR="${ED}" install || die "make install in ${1} failed"
}

src_install() {
	local myicon myres
	my_install "ManuProC_Base"
	my_install "ManuProC_Widgets"
	my_install "midgard"
	rm -rf -- "${ED}"/usr/include
	prune_libtool_files --all

	insinto "/usr/share/magus"

	my_cd "midgard"

	doins -r docs
	#doins xml/*.xml src/*.png src/*.tex

	for myicon in pixmaps/desktop-icons/MAGUS-*.png
	do	test -e "${myicon}" || continue
		myres=${myicon##*/MAGUS?}
		myres=${myres%.png}
		doicon -s "${myres}" "${myicon}"
	done
}
