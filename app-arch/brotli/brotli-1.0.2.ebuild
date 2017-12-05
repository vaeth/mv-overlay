# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )
DISTUTILS_OPTIONAL="1"

inherit cmake-utils distutils-r1 flag-o-matic

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli"
SRC_URI="https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"

RDEPEND="python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}"
RDEPEND+=" !<app-arch/archwrap-8"

IUSE="doc python static-libs test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

LICENSE="MIT python? ( Apache-2.0 )"

DOCS=( README.md CONTRIBUTING.md )

PATCHES=( "${FILESDIR}"/${PN}-1.0.1-no-rpath.patch )

src_prepare() {
	use static-libs || eapply "${FILESDIR}"/${PN}-1.0.1-no-static.patch
	cmake-utils_src_prepare
	use python && distutils-r1_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING="$(usex test)"
	)
	cmake-utils_src_configure
	if use python ; then
		filter-flags -fPIE -pie
		distutils-r1_src_configure
	fi
}

src_compile() {
	cmake-utils_src_compile
	use python && distutils-r1_src_compile
}

python_test(){
	esetup.py test || die
}

src_test() {
	cmake-utils_src_test
	use python && distutils-r1_src_test
}

src_install() {
	cmake-utils_src_install
	use python && distutils-r1_src_install
	use doc && dodoc docs/*.pdf
	doman docs/*.[0-9n]
}
