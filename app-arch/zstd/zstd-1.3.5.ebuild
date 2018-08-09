# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="zstd fast compression library"
HOMEPAGE="https://facebook.github.io/zstd/"
SRC_URI="https://github.com/facebook/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="|| ( BSD GPL-2 )"
SLOT="0/1"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
IUSE="legacy lz4 static-libs"

RDEPEND="app-arch/xz-utils
	lz4? ( app-arch/lz4 )"
DEPEND="${RDEPEND}"

src_compile() {
	local emake_args=(
		CC="$(tc-getCC)"
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)"
		PREFIX="${EPREFIX}/usr"
		LIBDIR="${EPREFIX}/usr/$(get_libdir)"
	)
	use legacy || emake_args+=(ZSTD_LEGACY_SUPPORT=8)
	emake "${emake_args[@]}" HAVE_LZ4=$(usex lz4 1 0) zstd

	emake -C lib  "${emake_args[@]}" libzstd

	emake -C contrib/pzstd "${emake_args[@]}"
}

src_install() {
	local emake_args=(
		DESTDIR="${D}"
		PREFIX="${EPREFIX}/usr"
		LIBDIR="${EPREFIX}/usr/$(get_libdir)"
	)
	use legacy || emake_args+=(ZSTD_LEGACY_SUPPORT=8)
	emake "${emake_args[@]}" install

	emake -C contrib/pzstd "${emake_args[@]}" install

	einstalldocs

	if ! use static-libs; then
		rm "${ED}"/usr/$(get_libdir)/libzstd.a || die
	fi
}
