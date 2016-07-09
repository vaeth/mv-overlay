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

IUSE=""
REQUIRED_USE=""

add_type_to_iuse() {
	local t i
	t=${1}
	shift
	REQUIRED_USE+=${REQUIRED_USE:+\ }'^^ ('
	for i
	do	IUSE+=${IUSE:+\ }${t}_${i}
		REQUIRED_USE+=" ${t}_${i}"
	done
	REQUIRED_USE+=' )'
}

BROWSERS="elinks firefox konqueror links lynx palemoon seamonkey"
PDFVIEWERS="acroread apvlv evince mupdf okular qpdfview zathura"
add_type_to_iuse browser ${BROWSERS}
IUSE+=" imagemagick"
add_type_to_iuse pdfviewer ${PDFVIEWERS}
IUSE+=" pngcrush postgres"

DEPENDCOMMON=">=dev-libs/libsigc++-2.6.2:2
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
	browser_elinks? ( www-client/elinks )
	browser_firefox? ( || ( www-client/firefox www-client/firefox-bin ) )
	browser_konqueror? ( kde-apps/konqueror )
	browser_links? ( www-client/links )
	browser_lynx? ( www-client/lynx )
	browser_palemoon? ( || ( www-client/palemoon www-client/palemoon-bin ) )
	browser_seamonkey? ( || ( www-client/seamonkey www-client/seamonkey-bin ) )
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

src_sed() {
	local short file ori
	short=${1}
	file="${S}/${short}"
	ori="${file}.ori"
	if ! test -e "${file}"
	then	die "Expected file ${short} does not exist"
	fi
	einfo "Patching ${short}"
	mv -- "${file}" "${ori}" || die
	shift
	sed "${@}" -- "${ori}" >"${file}" || die
	cmp -s -- "${ori}" "${file}" && ewarn "Unneeded patching of ${short}"
	rm -- "${ori}" || die
	return
}

patch_defaults() {
	local i browser pdfviewer
	for i in ${BROWSERS}
	do	use "browser_${i}" && browser=${i}
	done
	for i in ${PDFVIEWERS}
	do	use "pdfviewer_${i}" && pdfviewer=${i}
	done
	einfo
	einfo "Patching for browser ${browser}, default pdfviewer ${pdfviewer}:"
	einfo
	src_sed midgard/docs/BMod_Op.html -e "s#mozilla#${browser}#"
	src_sed midgard/libmagus/Magus_Optionen.cc -e "s#mozilla#${browser}#"
	src_sed midgard/midgard.glade \
		-e "s#mozilla#${browser}#" \
		-e "s#acroread#${pdfviewer}#"
	src_sed midgard/src/table_optionen_glade.cc \
		-e "s#mozilla#${browser}#" \
		-e "s#acroread#${pdfviewer}#"
	[ "${pdfviewer}" = "acroread" ] || {
		src_sed midgard/docs/Bedienung_Option.html \
			-e "s#AcrobatReader (acroread)#${pdfviewer}#"
	}
}

src_patch() {
	local i
	einfo
	einfo "Various patches:"
	einfo
	grep "saebel.png" midgard/src/Makefile.am && \
		ewarn "Unneeded patching of midgard/src/Makefile.am"
	src_sed midgard/src/Makefile.am \
		-e 's/drache.png/Money-gray.png saebel.png drache.png/'
	src_sed ManuProC_Widgets/configure.in \
		-e 's/^[[:space:]]*AM_GNU_GETTEXT_VERSION/AM_GNU_GETTEXT_VERSION/'
	grep "AM_GNU_GETTEXT_VERSION" ManuProC_Base/configure.in && \
		ewarn "Unneeded patching of ManuProC_Base/configure.in"
	src_sed ManuProC_Base/configure.in \
		-e '/AC_SUBST(GETTEXT_PACKAGE)/iAM_GNU_GETTEXT_VERSION([0.17])'
	src_sed midgard/src/table_lernschema.cc \
		-e '/case .*:$/{n;s/^[[:space:]]*\}/break;}/}'
	for i in \
		midgard/src/xml_fileselection.hh \
		midgard/libmagus/VAbenteurer.hh \
		ManuProC_Widgets/src/SimpleTreeModel.h \
		ManuProC_Widgets/src/ModelWidgetConnection.h \
		ManuProC_Widgets/src/TooltipView.h
	do	src_sed "${i}" -e 's!^\(#include <sigc++/object.h>\)!//\1!'
	done
	for i in \
		midgard/libmagus/VAbenteurer.cc \
		ManuProC_Base/src/RadioModel.h \
		ManuProC_Base/src/SignalPlex.h \
		ManuProC_Base/examples/mvc.cc
	do	src_sed "${i}" -e 's!^\(#include <sigc++/object_slot.h>\)!//\1!'
	done
	for i in \
		midgard/libmagus/KiDo.hh \
		midgard/libmagus/Zauber.hh \
		midgard/libmagus/Zauberwerk.hh
	do	src_sed "${i}" -e '/class .*[^;]$/{n;s/^{$/{ public:/}'
	done
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
	patch_defaults
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
	append-cxxflags -std=gnu++11 -fpermissive
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
