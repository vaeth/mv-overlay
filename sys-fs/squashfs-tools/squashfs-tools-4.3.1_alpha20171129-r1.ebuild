# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic toolchain-funcs

LIVE=false
PVm=4.3
case ${PV} in
*9999)
	LIVE=:;;
esac
Pm=${PN}-${PVm}
DEB_VER="6"

DESCRIPTION="Tool for creating compressed filesystem type squashfs"
HOMEPAGE="https://github.com/plougher/squashfs-tools/ https://git.kernel.org/pub/scm/fs/squashfs/squashfs-tools.git http://squashfs.sourceforge.net"
EXTRA_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PVm}-${DEB_VER}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="debug lz4 lzma lzo static xattr +xz +zstd"

LIB_DEPEND="sys-libs/zlib:=[static-libs(+)]
	lz4? ( app-arch/lz4:=[static-libs(+)] )
	lzma? ( app-arch/xz-utils:=[static-libs(+)] )
	lzo? ( dev-libs/lzo:=[static-libs(+)] )
	xattr? ( sys-apps/attr:=[static-libs(+)] )
	xz? ( app-arch/xz-utils:=[static-libs(+)] )
	zstd? ( >=app-arch/zstd-1.0:=[static-libs(+)] )"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )"

S="${WORKDIR}/squashfs${PV}/${PN}"

if ${LIVE}; then
	PROPERTIES="live"
	EGIT_REPO_URI="https://github.com/plougher/${PN}"
	inherit git-r3
	SRC_URI=${EXTRA_URI}
	KEYWORDS=""
	S="${WORKDIR}/${P}/${PN}"
src_unpack() {
	default
	git-r3_src_unpack
}
else
	RESTRICT="mirror"
	EGIT_COMMIT="fb33dfc32b131a1162dcf0e35bd88254ae10e265"
	SRC_URI="https://github.com/plougher/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
${EXTRA_URI}"
	S="${WORKDIR}/${P}/${PN}"
src_unpack() {
	default
	mv -- "${WORKDIR}/${PN}-${EGIT_COMMIT}" "${WORKDIR}/${P}"
}
fi

src_prepare() {
	local debian
	debian="${WORKDIR}"/debian/patches
	eapply -p2 "${debian}"/0001-kfreebsd.patch
	eapply -p2 "${debian}"/0003-CVE-2015-4645_and_CVE-2015-4646.patch
	eapply -p2 "${debian}"/0004-unsquashfs-add-support-for-LZMA-magics.patch
	eapply -p2 "${debian}"/0009-unsquashfs-preserve-symlink-times.patch
	eapply -p2 "${FILESDIR}"/${Pm}-sysmacros.patch
	eapply -p2 "${FILESDIR}"/${Pm}-aligned-data.patch
	eapply "${FILESDIR}"/${Pm}-local-cve-fix.patch
	eapply "${FILESDIR}"/${Pm}-static-inline.patch
	default
}

use10() {
	usex $1 1 0
}

src_configure() {
	# set up make command line variables in EMAKE_SQUASHFS_CONF
	EMAKE_SQUASHFS_CONF=(
		LZMA_XZ_SUPPORT=$(use10 lzma)
		LZO_SUPPORT=$(use10 lzo)
		LZ4_SUPPORT=$(use10 lz4)
		XATTR_SUPPORT=$(use10 xattr)
		XZ_SUPPORT=$(use10 xz)
		ZSTD_SUPPORT=$(use10 zstd)
	)
	filter-flags -fno-common

	tc-export CC
	use debug && append-cppflags -DSQUASHFS_TRACE
	use static && append-ldflags -static
}

src_compile() {
	emake "${EMAKE_SQUASHFS_CONF[@]}"
}

src_install() {
	dobin mksquashfs unsquashfs
	cd ..
	dodoc CHANGES README RELEASE-README ACKNOWLEDGEMENTS RELEASE-READMEs/*
	doman "${WORKDIR}"/debian/manpages/*.[0-9]
}
