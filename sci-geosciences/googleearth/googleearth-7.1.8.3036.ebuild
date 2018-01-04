# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop eutils gnome2-utils pax-utils unpacker versionator xdg-utils

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="https://www.google.com/earth/desktop/"
MY_PV=$(replace_all_version_separators '_' $(get_version_component_range 1-3))
SRC_URI="x86? ( https://dl.google.com/dl/earth/client/GE7/release_${MY_PV}/google-earth-pro-stable_${PV}-r0_i386.deb )
	amd64? ( https://dl.google.com/dl/earth/client/GE7/release_${MY_PV}/google-earth-pro-stable_${PV}-r0_amd64.deb )"
LICENSE="googleearth GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror splitdebug"
IUSE="+bundled-libs"

QA_PREBUILT="*"

# TODO: find a way to unbundle libQt
# ./googleearth-bin: symbol lookup error: ./libbase.so: undefined symbol: _Z34QBasicAtomicInt_fetchAndAddOrderedPVii

RDEPEND="
	dev-libs/glib:2
	dev-libs/nspr
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	sys-devel/gcc[cxx]
	sys-libs/zlib
	virtual/glu
	virtual/opengl
	virtual/ttf-fonts
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/libXau
	x11-libs/libXdmcp
	!bundled-libs? (
		dev-db/sqlite:3
		dev-libs/expat
		dev-libs/nss
		sci-libs/proj
	)"
#		sci-libs/gdal-1*
DEPEND="dev-util/patchelf"

S=${WORKDIR}/opt/google/earth/pro

src_unpack() {
	# default src_unpack fails with deb2targz installed, also this unpacks the data.tar.lzma as well
	unpack_deb ${A}

	if ! use bundled-libs ; then
		einfo "removing bundled libs"
		cd opt/google/earth/pro || die
		# sci-libs/gdal-1*
		# rm -v libgdal.so.1 || die
		# dev-db/sqlite
		rm -v libsqlite3.so || die
		# dev-libs/nss
		rm -v libplc4.so libplds4.so libnspr4.so libnssckbi.so libfreebl3.so \
			libnssdbm3.so libnss3.so libnssutil3.so libsmime3.so libnsssysinit.so \
			libsoftokn3.so libssl3.so || die
		# dev-libs/expat
		rm -v libexpat.so.1 || die
		# sci-libs/proj
		rm -v libproj.so.0 || die
		# dev-qt/qtcore:4 dev-qt/qtgui:4 dev-qt/qtwebkit:4
#		rm -v libQt{Core,Gui,Network,WebKit}.so.4 || die
#		rm -rv plugins/imageformats || die
	fi
}

src_prepare() {

	# we have no ld-lsb.so.3 symlink
	# thanks to Nathan Phillip Brink <ohnobinki@ohnopublishing.net> for suggesting patchelf
	einfo "running patchelf"
	patchelf --set-interpreter /$(get_libdir)/ld-linux$(usex amd64 "-x86-64" "").so.2 ${PN}-bin || die "patchelf failed"

	# Set RPATH for preserve-libs handling (bug #265372).
	local x
	for x in * ; do
		# Use \x7fELF header to separate ELF executables and libraries
		[[ -f ${x} && $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] || continue
		fperms u+w "${x}"
		patchelf --set-rpath '$ORIGIN' "${x}" ||
			die "patchelf failed on ${x}"
	done
	# prepare file permissions so that >patchelf-0.8 can work on the files
	fperms u+w plugins/*.so plugins/imageformats/*.so
	for x in plugins/*.so ; do
		[[ -f ${x} ]] || continue
		patchelf --set-rpath '$ORIGIN/..' "${x}" ||
			die "patchelf failed on ${x}"
	done
	for x in plugins/imageformats/*.so ; do
		[[ -f ${x} ]] || continue
		patchelf --set-rpath '$ORIGIN/../..' "${x}" ||
			die "patchelf failed on ${x}"
	done

	eapply -p0 "${FILESDIR}"/${PN}-${PV%%.*}-pro-desktopfile.patch
	default
}

src_install() {
	make_wrapper ${PN} ./${PN} /opt/${PN} .

	insinto /usr/share/mime/packages
	doins "${FILESDIR}/${PN}-mimetypes.xml" || die

	domenu google-earth-pro.desktop

	local size
	for size in 16 22 24 32 48 64 128 256 ; do
		newicon -s ${size} product_logo_${size}.png google-earth-pro.png
	done

	rm -rf xdg-mime xdg-settings google-earth-pro google-earth-pro.desktop product_logo_*

	insinto /opt/${PN}
	doins -r *

	fperms +x /opt/${PN}/${PN}{,-bin}
	cd "${ED}" || die
	find . -type f -name "*.so.*" -exec fperms +x '{}' +

	pax-mark -m "${ED%/}"/opt/${PN}/${PN}-bin
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "When you get a crash starting Google Earth, try adding a file ~./.config/Google/GoogleEarthPlus.conf"
	elog "with the following options:"
	elog "lastTip = 4"
	elog "enableTips = false"
	elog ""
	elog "In addition, the use of free video drivers may cause problems associated with using the Mesa"
	elog "library. In this case, Google Earth 6x likely only works with the Gallium3D variant."
	elog "To select the 32bit graphic library use the command:"
	elog "	eselect mesa list"
	elog "For example, for Radeon R300 (x86):"
	elog "	eselect mesa set r300 2"
	elog "For Intel Q33 (amd64):"
	elog "	eselect mesa set 32bit i965 2"
	elog "You may need to restart X afterwards"

	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	gnome2_icon_cache_update
}
