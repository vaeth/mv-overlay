# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit autotools flag-o-matic

DESCRIPTION="FUSE filesystem to mount squashfs archives"
HOMEPAGE="https://github.com/vasi/squashfuse"

case ${PV} in
*alpha*)
	EGIT_COMMIT="0b48352ed7a89d920bb6792ac59f9f6775088f02"
	SRC_URI="https://github.com/vasi/squashfuse/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S=${WORKDIR}/${PN}-${EGIT_COMMIT}
	alpha=:;;
*)
	SRC_URI="https://github.com/vasi/squashfuse/archive/${PV}/${P}.tar.gz"
	alpha=false;;
esac

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~arm-linux ~x86-linux"
IUSE="lz4 lzma lzo static-libs +zlib zstd"
REQUIRED_USE="|| ( lz4 lzma lzo zlib zstd )"

COMMON_DEPEND="
	>=sys-fs/fuse-2.8.6:0=
	lzma? ( >=app-arch/xz-utils-5.0.4:= )
	zlib? ( >=sys-libs/zlib-1.2.5-r2:= )
	lzo? ( >=dev-libs/lzo-2.06:= )
	lz4? ( >=app-arch/lz4-0_p106:= )
	zstd? ( >=app-arch/zstd-1.0:= )
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_prepare() {
	default
	! $alpha || sed -i -e '1s:\[0\.1\.100\]:['"${PV}"']:' configure.ac || die
	AT_M4DIR=${S}/m4 eautoreconf
}

src_configure() {
	filter-flags '-flto*' -fwhole-program -fno-common
	local myconf=(
		$(use lz4 || echo --without-lz4)
		$(use lzma || echo  --without-xz)
		$(use lzo || echo --without-lzo)
		$(use zlib || echo --without-zlib)
		$(use zstd || echo --without-zstd)
		$(use static-libs || echo --disable-static)
	)
	econf "${myconf[@]}"
}
