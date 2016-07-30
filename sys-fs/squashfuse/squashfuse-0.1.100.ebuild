# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit flag-o-matic

DESCRIPTION="FUSE filesystem to mount squashfs archives"
HOMEPAGE="https://github.com/vasi/squashfuse"
SRC_URI="https://github.com/vasi/squashfuse/releases/download/${PV}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~arm-linux ~x86-linux"
IUSE="lzma lzo +zlib"
REQUIRED_USE="|| ( lzma zlib lzo )"

COMMON_DEPEND="
	>=sys-fs/fuse-2.8.6:=
	lzma? ( >=app-arch/xz-utils-5.0.4:= )
	zlib? ( >=sys-libs/zlib-1.2.5-r2:= )
	lzo? ( >=dev-libs/lzo-2.06:= )
"
DEPEND="app-arch/unzip
	${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_configure() {
	filter-flags -flto* -fwhole-program -fno-common
	econf \
		$(use lzma || echo  --without-xz) \
		$(use lzo || echo --without-lzo) \
		$(use zlib || echo --without-zlib)
}
