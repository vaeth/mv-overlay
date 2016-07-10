# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Support for printing to ZjStream-based printers"
HOMEPAGE="http://foo2zjs.rkkda.com/"
SRC_URI="http://foo2zjs.rkkda.com/${PN}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="+cups"
IUSE_LATER="foomaticdb test"
# due to those firmwares/icms/etc...
RESTRICT="mirror"

PATCHES=("${FILESDIR}/foreground.patch")

COMMON="foomaticdb? ( net-print/foomatic-db-engine )"
RDEPEND="${COMMON}
	cups? (
		net-print/cups
		|| ( >=net-print/cups-filters-1.0.43 net-print/foomatic-filters )
	)
	virtual/udev"
DEPEND="${COMMON}
	app-arch/unzip
	app-editors/vim
	sys-apps/ed
	sys-devel/bc
	test? ( sys-process/time )"

S="${WORKDIR}/${PN}"

print_url() {
	local i curr verdata usual
	usual='20130105'
	curr=
	verdata=false
	for i
	do	if ${verdata}
		then	verdata=false
			print_url_sub "${curr}" "${i}"
			curr=
		elif [ "$i" = '->' ]
		then	verdata=:
		else	print_url_sub "${curr}" "${usual}"
			curr=${i}
		fi
	done
	print_url_sub "${curr}" "${usual}"
}

print_url_sub() {
	local base ext
	[ -z "${1:++}" ] && return
	if [ -z "${2:++}" ]
	then	printf '%s\n' "${1}"
		return
	fi
	base=${1##*/}
	ext=${base##*.}
	base=${base%.*}
	case ${base} in
	*.[!.][!.][!.])
		ext=${base##*.}.${ext}
		base=${base%.*}
	;;
	esac
	printf '%s %s %s\n' "${1}" '->' "${base}-${2}.${ext}"
}

init_data() {
	local i flag url readflag sihp most
	sihp='-> 20100501'
	readflag=:
	# see getweb or getweb.in
	for i in \
	'hp1000' "http://foo2zjs.rkkda.com/firmware/sihp1000.tar.gz ${sihp}" \
	'hp1005' "http://foo2zjs.rkkda.com/firmware/sihp1005.tar.gz ${sihp}
http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz ${sihp}" \
	'hp1018' "http://foo2zjs.rkkda.com/firmware/sihp1018.tar.gz ${sihp}" \
	'hp1020' "http://foo2zjs.rkkda.com/firmware/sihp1020.tar.gz ${sihp}" \
	'hpp1005' "http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz ${sihp}" \
	'hpp1007' \" \
	'hpp1006' "http://foo2zjs.rkkda.com/firmware/sihpP1006.tar.gz ${sihp}" \
	'hpp1008' \" \
	'hpp1505' "http://foo2zjs.rkkda.com/firmware/sihpP1505.tar.gz ${sihp}" \
	'km2200' "http://foo2zjs.rkkda.com/icm/dl2300.tar.gz" \
	'km2300' "http://foo2zjs.rkkda.com/icm/dl2300.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz" \
	'kmcpwl' "http://foo2zjs.rkkda.com/icm/dl2300.tar.gz" \
	'km2430' "http://foo2zjs.rkkda.com/icm/km2430.tar.gz" \
	'km2530' "http://foo2lava.rkkda.com/icm/km2530.tar.gz
http://foo2lava.rkkda.com/icm/km-1600.tar.gz" \
	'km2490' \" \
	'km2480' \" \
	'xp6115' \" \
	'hp1500' "http://foo2hp.rkkda.com/icm/hpclj2500.tar.gz
http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz" \
	'hp1025' "http://foo2zjs.rkkda.com/icm/hp-cp1025.tar.gz" \
	'hp1215' "http://foo2hp.rkkda.com/icm/hpclj2600n.tar.gz
http://foo2zjs.rkkda.com/icm/km2430.tar.gz
http://foo2hp.rkkda.com/icm/hp1215.tar.gz" \
	'hp1600' \" \
	'hp2600n' \" \
	'sa300' "http://foo2qpdl.rkkda.com/icm/samclp300.tar.gz
http://foo2qpdl.rkkda.com/icm/samclp315.tar.gz" \
	'sa310' \" \
	'sa315' \" \
	'sa325' \" \
	'sa360' \" \
	'sa365' \" \
	'sa2160' \" \
	'sa3160' \" \
	'sa3175' \" \
	'sa3185' \" \
	'xp6110' \" \
	'sa600' '' \
	'sa610' \" \
	'lm500' "http://foo2slx.rkkda.com/icm/lexc500.tar.gz" \
	'oki301' "http://foo2hiperc.rkkda.com/icm/okic310.tar.gz" \
	'oki310' "http://foo2hiperc.rkkda.com/icm/okic310.tar.gz" \
	'oki511' "http://foo2hiperc.rkkda.com/icm/okic511.tar.gz -> 20150212" \
	'oki810' "http://foo2hiperc.rkkda.com/icm/okic810.tar.gz -> 20131118" \
	'oki3100' "http://foo2hiperc.rkkda.com/icm/okic3200.tar.gz" \
	'oki3200' \" \
	'oki5100' \" \
	'oki5150' \" \
	'oki5200' \" \
	'oki5250' \" \
	'oki3300' "http://foo2hiperc.rkkda.com/icm/okic3400.tar.gz" \
	'oki3400' \" \
	'oki3530' \" \
	'oki5500' "http://foo2hiperc.rkkda.com/icm/okic5600.tar.gz" \
	'oki5600' \" \
	'oki5800' \" \
	'oli160' \"
	do	if ${readflag}
		then	readflag=false
			flag=${i}
			IUSE=${IUSE-}${IUSE:+\ }"+foo2zjs_devices_${flag}"
		else	readflag=:
			if [ -n "${i}" ]
			then	[ "${i}" = \" ] || url='? ( '$(print_url ${i})' )'
				SRC_URI="${SRC_URI}
foo2zjs_devices_${flag}${url}"
			fi
		fi
	done
	${readlag} || \
		die "internal ebuild error: odd number of args in init_data()"
	[ -z "${IUSE_LATER:++}" ] || IUSE=${IUSE-}${IUSE:+\ }${IUSE_LATER-}
}
init_data

src_unpack() {
	local i
	default
	for i in *
	do	case "${S}" in
		*/"${i}") continue;;
		esac
		if test -d "${i}"
		then	chmod 755 -- "${i}" || die "chmod dir ${i} failed"
		else	chmod 644 -- "${i}" || die "chmod file ${i} failed"
		fi
		mv -- "${i}" "${S}" || die "Move failed"
	done
}

src_prepare() {
	sed \
		-e 's/$(MAKE)/$(MAKE) CFLAGS="$(CFLAGS)"/' \
		-e 's~-x /sbin/udevd~-z ""~' \
		-e 's~/sbin/udevd --version~echo 200~' \
		-e 's~^CFLAGS~#CFLAGS~' \
		-e 's~/usr/local~/usr~' \
		-i Makefile
#		-e "s~/lib/udev~${ED%/}/lib/udev~g" \
#		-e "s~/etc~${ED%/}/etc~g" \
#		-e 's/ install-filter / /g' \
	sed -e "s~/etc~${ED%/}/etc~g" \
		-e "s~/lib/udev~${ED%/}/lib/udev~g" \
		-i hplj1000
	sed -e 's/chmod -w/sleep 2; chmod -w/' \
		-i osx-hotplug/Makefile
	eapply_user
}

src_compile() {
	CFLAGS="${CFLAGS-} ${LDFLAGS-}"
	default
}

src_install() {
	# ppd files are installed automagically. We have to create a directory
	# for them.
	dodir /usr/share/ppd

	# Also for the udev rules we have to create a directory to install them.
	dodir /lib/udev/rules.d

	# directories we have to create if we want foomaticdb support
	use foomaticdb && dodir /usr/share/foomatic/db/source

	# Directories we have to create if we want filters
	use cups && dodir /usr/libexec/cups/filter

	emake DESTDIR="${ED%/}" \
		USBDIR="${ED%/}/etc/hotplug/usb" \
		UDEVDIR="${ED%/}/lib/udev/rules.d" \
		LIBUDEVDIR="${ED%/}/lib/udev/rules.d" \
		-j1 install install-hotplug
}
