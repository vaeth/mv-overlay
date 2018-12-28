# Copyright 1999-2018 Martin V\"ath and Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
AT_NOELIBTOOLIZE=yes
inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="A network programming library in C++"
HOMEPAGE="http://alumnit.ca/wiki/?WvStreams"
case ${PV} in
*alpha*)
	EGIT_COMMIT="dac7d0f784845a8b43d45f64fdf43fd5f4833a34"
	SRC_URI="https://github.com/apenwarr/wvstreams/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S=${WORKDIR}/${PN}-${EGIT_COMMIT};;
*)
	SRC_URI="https://wvstreams.googlecode.com/files/${P}.tar.gz"
esac


LICENSE="GPL-2"
SLOT="0/5pre"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~sparc ~x86"
IUSE="pam +dbus debug doc +ssl static-libs zlib"

#Tests fail if openssl is not compiled with -DPURIFY. Gentoo's isn't. FAIL!
RESTRICT="test"

#QA Fail: xplc is compiled as a part of wvstreams.
#It'll take a larger patching effort to get it extracted, since upstream integrated it
#more tightly this time. Probably for the better since upstream xplc seems dead.

RDEPEND="
	ssl? ( >=dev-libs/openssl-1.1:0= )
	sys-libs/readline:0=
	zlib? ( sys-libs/zlib )
	dbus? ( >=sys-apps/dbus-1.4.20 )
	pam? ( virtual/pam )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

src_prepare() {
	mv config.ac configure.ac
	mkdir build
	default
	eautoreconf
}

src_configure() {
	append-flags -fno-strict-aliasing
	append-flags -fno-tree-dce -fno-optimize-sibling-calls #421375

	tc-export AR CC CXX

	cd build
	ECONF_SOURCE="$S" econf \
		$(use_enable debug) \
		$(use_with dbus) \
		$(use_with pam) \
		$(use_with ssl openssl) \
		$(use_with zlib) \
		--cache-file="${BUILD_DIR}"/config.cache \
		--disable-optimization \
		--localstatedir=/var \
		--without-qt \
		--without-valgrind
}

src_compile() {
	if use doc; then
		doxygen "${S}"/Doxyfile || die
	fi
	cd build
	emake
}

src_test() {
	emake check
}

src_install() {
	if use doc; then
		docinto html
		dodoc -r Docs/doxy-html/*
	fi
	cd build
	emake DESTDIR="${ED}" install || die
	insinto /usr/include
	doins include/wvautoconf.h
	insinto /usr/$(get_libdir)/pkgconfig
	local lib
	for lib in $(find "${BUILD_DIR}" -name '*.so' -type l | grep -v libwvstatic); do
		doins "${BUILD_DIR}"/pkgconfig/$(basename ${lib/.so}).pc
	done
	use static-libs || find "${ED}" -name '*.a' -delete || die
}
