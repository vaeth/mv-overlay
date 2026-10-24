# Copyright 2017-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib mercurial

IUSE="usb"
SLOT="0"
HOMEPAGE="http://www.linuxtv.org/"
DESCRIPTION="small utils for DVB to scan, zap, view signal strength, ..."
SRC_URI=""
LICENSE="GPL-2"
EHG_REPO_URI="http://linuxtv.org/hg/dvb-apps"
KEYWORDS=""

RDEPEND="usb? ( virtual/libusb:0 )
	!dev-db/xbase"
DEPEND="${RDEPEND}
	virtual/linuxtv-dvb-headers"
# !dev-db/xbase (bug #208596)

#S="${WORKDIR}/dvb-apps-7de0663facd9"

src_prepare() {
	# do not compile test-progs
	sed -i -e '/-C test/d' -- "${S}"/Makefile

	# remove copy of header-files
	rm -rf -- "${S}"/include
}

src_compile() {
	# ttusb_dec_reset requires libusb
	myopts=""
	use usb && myopts="${myopts} ttusb_dec_reset=1"

	emake bindir=/usr/bin datadir=/usr/share libdir=/usr/$(get_libdir) \
		${myopts} || die "failed to compile"
}

src_install() {
	insinto /usr/bin
	emake bindir=/usr/bin datadir=/usr/share libdir=/usr/$(get_libdir) prefix=/usr \
		DESTDIR="${ED}" INSTDIR="${T}" ${myopts} install || die "install failed"

	# rename scan to dvbscan
	mv -- "${ED}"/usr/bin/scan "${ED}"/usr/bin/dvbscan

	# install zap-files
	for dir in dvb-{s,c,t} atsc; do
		insinto /usr/share/dvb/zap/${dir}
		doins "${S}"/util/szap/channels-conf/${dir}/*
	done

	# install remote-key files
	insinto /usr/share/dvb/av7110_loadkeys
	doins "${S}"/util/av7110_loadkeys/*.rc*

	# install Documentation
	dodoc README
	newdoc util/scan/README README.dvbscan
	newdoc util/szap/README README.zap
	newdoc util/av7110_loadkeys/README README.av7110_loadkeys

	use usb && newdoc util/ttusb_dec_reset/README README.ttusb_dec_reset
}

pkg_postinst() {
	elog "Please read the documentation in /usr/share/doc/${PF}."
	elog "The channel lists and other files are installed in"
	elog "/usr/share/dvb"
	elog
	elog "The scanning utility is now installed as dvbscan."
}
