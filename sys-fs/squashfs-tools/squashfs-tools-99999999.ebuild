# Copyright 1999-2019 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit flag-o-matic toolchain-funcs

PVm=4.3
DEB_VER="12"

DESCRIPTION="Tool for creating compressed filesystem type squashfs"
HOMEPAGE="https://github.com/plougher/squashfs-tools/ https://git.kernel.org/pub/scm/fs/squashfs/squashfs-tools.git http://squashfs.sourceforge.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="debug lz4 lzma lzo static xattr +xz +zstd"
EXTRA_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PVm}-${DEB_VER}.debian.tar.xz"

case ${PV} in
*9999)
	PROPERTIES="live"
	EGIT_REPO_URI="https://github.com/plougher/${PN}"
	inherit git-r3
	SRC_URI=${EXTRA_URI}
	KEYWORDS=""
src_unpack() {
	default
	git-r3_src_unpack
};;
*alpha*)
	RESTRICT="mirror"
	EGIT_COMMIT="52eb4c279cd283ed9802dd1ceb686560b22ffb67"
	SRC_URI="https://github.com/plougher/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz
${EXTRA_URI}"
src_unpack() {
	default
	mv -- "${WORKDIR}/${PN}-${EGIT_COMMIT}" "${WORKDIR}/${P}"
};;
*)
	RESTRICT="mirror"
	SRC_URI="https://github.com/plougher/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
${EXTRA_URI}";;
esac
S="${WORKDIR}/${P}/${PN}"

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

src_prepare() {
	local Pm debian
	Pm=${PN}-${PVm}
	debian="${WORKDIR}"/debian/patches
	eapply -p2 "${debian}"/0001-kfreebsd.patch
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
	dodoc CHANGES README README-4.4 ACKNOWLEDGEMENTS USAGE RELEASE-READMEs/*
	doman "${WORKDIR}"/debian/manpages/*.[0-9]
}
