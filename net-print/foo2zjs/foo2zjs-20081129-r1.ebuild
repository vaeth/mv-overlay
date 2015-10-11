# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils

DESCRIPTION="Support for printing to ZjStream-based printers. Fixes bug 271079"
HOMEPAGE="http://foo2zjs.rkkda.com/"

# extracted by http://gentooexperimental.org/~genstef/dist/foo2zjs-helper.sh
DEVICES=( "hp2600n" "hp1600" "hp1500" "hp1215" "km2530" "km2490" "km2480"
"xp6115" "km2430" "km2300" "km2200" "kmcpwl" "sa300" "sa315"  "sa2160"
"sa3160" "xp6110" "lm500" "oki3200" "oki3300" "oki3400" "oki3530" "oki5100"
"oki5200" "oki5500" "oki5600" "oki5800" "hp1020" "hp1018" "hp1005" "hp1000"
"hpp1505" "hpp1008" "hpp1007" "hpp1006" "hpp1005" )
#"sa610" has no file to download
URIS=(
"http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"http://foo2lava.rkkda.com/icm/km2530.tar.gz"
"http://foo2lava.rkkda.com/icm/km2530.tar.gz"
"http://foo2lava.rkkda.com/icm/km2530.tar.gz"
"http://foo2lava.rkkda.com/icm/km2530.tar.gz"
"http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"ftp://ftp.minolta-qms.com/pub/crc/out_going/other/m23dlicc.exe
http://foo2zjs.rkkda.com/icm/km2430.tar.gz"
"ftp://ftp.minolta-qms.com/pub/crc/out_going/win2000/m22dlicc.exe"
"ftp://ftp.minolta-qms.com/pub/crc/out_going/windows/cpplxp.exe"
"http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz"
"http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz"
"http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz"
"http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz"
"http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz"
"http://foo2slx.rkkda.com/icm/lexc500.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3200.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3400.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3400.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3400.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3200.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic3200.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic5600.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic5600.tar.gz"
"http://foo2hiperc.rkkda.com/icm/okic5600.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihp1020.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihp1018.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihp1005.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihp1000.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihpP1505.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihpP1006.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihpP1006.tar.gz"
"http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz"
)

SRC_URI="http://dev.gentooexperimental.org/~scarabeus/${P}.tar.gz"
IUSE="cups foomaticdb usb"
for ((DEV=0; DEV < ${#DEVICES[*]}; DEV++)); do
	SRC_URI="${SRC_URI} foo2zjs_devices_${DEVICES[DEV]}? ( ${URIS[DEV]} )"
	IUSE="${IUSE} foo2zjs_devices_${DEVICES[DEV]}"
	ALL_BEGIN="${ALL_BEGIN} !foo2zjs_devices_${DEVICES[DEV]}? ("
	ALL_MIDDLE="${ALL_MIDDLE} ${URIS[DEV]}"
	ALL_END="${ALL_END} )"
done
SRC_URI="${SRC_URI}${ALL_BEGIN}${ALL_MIDDLE}${ALL_END}"

LICENSE="GPL-2"
# due to those firmwares/icms/etc...
RESTRICT="mirror"
SLOT="0"
DEPEND="app-arch/unzip"
RDEPEND="cups? ( net-print/cups )
	foomaticdb? ( net-print/foomatic-db-engine )
	net-print/foomatic-filters
	virtual/udev"
KEYWORDS="~x86 ~amd64 ~ppc"
S="${WORKDIR}/${PN}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-Makefile.patch
	epatch "${FILESDIR}"/${P}-udevfwld.patch
	epatch_user
}

src_unpack() {
	unpack ${P}.tar.gz

	# link getweb files in ${S} to get unpacked
	local i
	for i in ${A}
	do	ln -s "${DISTDIR}"/${i} "${S}"
	done
}

src_compile() {
	emake getweb

	# remove wget as we got the firmware with portage
	sed -i -e "s/.*wget .*//" \
		-e 's/.*rm $.*//' \
		-e "s/error \"Couldn't dow.*//" getweb

	# unpack files
	GOT=0;
	for ((DEV=0; DEV < ${#DEVICES[*]}; DEV++)); do
		if use foo2zjs_devices_${DEVICES[DEV]}; then
			./getweb ${DEVICES[DEV]:2}
			GOT=1
		fi
	done
	if [ ${GOT} == 0 ]; then ./getweb all; fi

	emake
}

src_install() {
	use foomaticdb && dodir /usr/share/foomatic/db/source

	use cups && dodir /usr/share/cups/model

	emake DESTDIR="${ED}" install install-udev
}
