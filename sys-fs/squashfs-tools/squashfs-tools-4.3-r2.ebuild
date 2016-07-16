# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit flag-o-matic toolchain-funcs

LIVE=false
PVm=${PV}
case ${PV} in
*9999)
	LIVE=:
	PVm=4.3;;
esac
Pm=${PN}-${PVm}
DEB_VER="3"

DESCRIPTION="Tool for creating compressed filesystem type squashfs. Patched to support -quiet"
HOMEPAGE="http://squashfs.sourceforge.net"
EXTRA_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PVm}-${DEB_VER}.debian.tar.xz"
SRC_URI="mirror://sourceforge/squashfs/squashfs${PV}.tar.gz
	${EXTRA_URI}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="lz4 lzma lzo xattr +xz"

RDEPEND="
	sys-libs/zlib
	!xz? ( !lzo? ( sys-libs/zlib ) )
	lz4? ( app-arch/lz4 )
	lzma? ( app-arch/xz-utils )
	lzo? ( dev-libs/lzo )
	xattr? ( sys-apps/attr )
	xz? ( app-arch/xz-utils )
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/squashfs${PV}/${PN}"

if ${LIVE}
then	PROPERTIES="live"
	EGIT_REPO_URI="git://github.com/plougher/${PN}"
	inherit git-r3
	SRC_URI=${EXTRA_URI}
	KEYWORDS=""
	S="${WORKDIR}/${P}/${PN}"
src_unpack() {
	default
	git-r3_src_unpack
}
fi

src_prepare() {
	local i j
	for i in "${WORKDIR}"/debian/patches/*.patch
	do	${LIVE} && j=${i##*/} && case ${j%.*} in
		0002-fix_phys_mem_calculation)
			continue;;
		esac
		eapply -p2 "${i}"
	done
	eapply -p2 "${FILESDIR}"/${Pm}-sysmacros.patch
	eapply -p2 "${FILESDIR}"/${Pm}-aligned-data.patch
	${LIVE} || eapply -p2 "${FILESDIR}"/${Pm}-2gb.patch
	eapply -p1 "${FILESDIR}"/${Pm}-local-cve-fix.patch
	${LIVE} || eapply -p2 "${FILESDIR}"/${Pm}-mem-overflow.patch
	eapply -p2 "${FILESDIR}"/${Pm}-xattrs.patch
	eapply "${FILESDIR}"/${Pm}-quiet.patch
	eapply_user
}

use10() { usex $1 1 0 ; }

src_configure() {
	# set up make command line variables in EMAKE_SQUASHFS_CONF
	EMAKE_SQUASHFS_CONF=(
		LZMA_XZ_SUPPORT=$(use10 lzma)
		LZO_SUPPORT=$(use10 lzo)
		LZ4_SUPPORT=$(use10 lz4)
		XATTR_SUPPORT=$(use10 xattr)
		XZ_SUPPORT=$(use10 xz)
	)
	filter-flags -fno-common

	tc-export CC
}

src_compile() {
	emake "${EMAKE_SQUASHFS_CONF[@]}"
}

src_install() {
	dobin mksquashfs unsquashfs
	cd ..
	dodoc CHANGES README*
	${LIVE} || dodoc PERFORMANCE.README pseudo-file.example OLD-READMEs/*
	doman "${WORKDIR}"/debian/manpages/*.[0-9]
}
