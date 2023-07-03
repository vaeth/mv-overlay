# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

inherit cmake

DESCRIPTION="An implementation of encrypted filesystem in user-space using FUSE"
HOMEPAGE="https://vgough.github.io/encfs/"
case ${PV} in
*alpha*)
	EGIT_COMMIT="c5e5651f02b8aa7a5acd1737253780decf71636c"
	SRC_URI="https://github.com/doj/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
*)
	SRC_URI="https://github.com/vgough/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
esac

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="amd64 arm ~ppc64 ~sparc x86"
IUSE="nls"

RDEPEND="dev-libs/openssl:=
	dev-libs/tinyxml2:=
	sys-fs/fuse:3=
	sys-libs/zlib"
DEPEND="${RDEPEND}"
BDEPEND="dev-lang/perl
	sys-devel/gettext
	virtual/pkgconfig"

# Build dir is hardcoded in test suite, but we restrict them
# because they can lead to false negatives, bug #630486
RESTRICT="test"

BUILD_DIR="${S}/build"

src_configure() {
	local mycmakeargs=(
		-DENABLE_NLS="$(usex nls)"
		-DUSE_INTERNAL_TINYXML=OFF
		-DBUILD_UNIT_TESTS=OFF
		-DBUILD_SHARED_LIBS=ON
		# Needed with BUILD_SHARED_LIBS=ON
		-DINSTALL_LIBENCFS=ON
		-DLIB_INSTALL_DIR="$(get_libdir)"
	)
	cmake_src_configure
}
