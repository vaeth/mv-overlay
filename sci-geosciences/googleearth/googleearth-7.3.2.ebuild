# Copyright 1999-2019 Martin V\"ath and others
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils pax-utils unpacker xdg-utils

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="https://www.google.com/earth/desktop/"
SRC_URI="https://dl.google.com/dl/linux/direct/google-earth-pro-stable_${PV}_amd64.deb"
LICENSE="googleearth GPL-2"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror splitdebug"
IUSE="+bundled-qt"

QA_PREBUILT="*"

RDEPEND="
	dev-libs/glib:2
	dev-libs/nspr
	media-libs/fontconfig
	media-libs/freetype
	media-libs/gstreamer:1.0=
	media-libs/gst-plugins-base:1.0=
	net-libs/libproxy
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
	!bundled-qt? (
		dev-qt/qtcore:5
		dev-qt/qtdbus:5
		dev-qt/qtdeclarative:5
		dev-qt/qtgui:5
		dev-qt/qtmultimedia:5[widgets]
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtpositioning:5
		dev-qt/qtprintsupport:5
		dev-qt/qtsensors:5
		dev-qt/qtscript:5[scripttools]
		dev-qt/qtwebchannel:5
		dev-qt/qtwebkit:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
	)"
#		sci-libs/gdal-1*
BDEPEND="dev-util/patchelf"

S=${WORKDIR}/opt/google/earth/pro

src_unpack() {
	# default src_unpack fails with deb2targz installed, also this unpacks the data.tar.lzma as well
	unpack_deb ${A}

	cd opt/google/earth/pro || die
	if ! use bundled-qt ; then
		einfo "removing bundled qt"
		rm -v libQt5{Core,DBus,Gui,Multimedia,MultimediaWidgets,Network,OpenGL,Positioning,PrintSupport,Qml,Quick,Script,ScriptTools,Sensors,Sql,WebChannel,WebKit,WebKitWidgets,Widgets,X11Extras,XcbQpa}.so.5 || die
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
		chmod u+w "${x}" || die
		patchelf --set-rpath '$ORIGIN' "${x}" || \
			die "patchelf failed on ${x}"
	done
	for x in plugins/*.so ; do
		[[ -f ${x} ]] || continue
		chmod u+w "${x}" || die
		patchelf --set-rpath '$ORIGIN/..' "${x}" || \
			die "patchelf failed on ${x}"
	done
	for x in plugins/imageformats/*.so ; do
		[[ -f ${x} ]] || continue
		chmod u+w "${x}" || die
		patchelf --set-rpath '$ORIGIN/../..' "${x}" || \
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

	chmod +x "${ED}"/opt/${PN}/{${PN}{,-bin},repair_tool,gpsbabel} || die
	find "${ED}" -type f '(' -name '*.so.*' -o -name '*.so' ')' -exec chmod +x '{}' + || die

	pax-mark -m "${ED%/}"/opt/${PN}/${PN}-bin
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
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}
