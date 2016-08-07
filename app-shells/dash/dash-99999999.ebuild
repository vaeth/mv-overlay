# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/dash/dash.git"
WANT_LIBTOOL=none
AT_NOELIBTOOLIZE=true
inherit autotools eutils flag-o-matic git-r3 toolchain-funcs

DESCRIPTION="DASH is a direct descendant of the NetBSD version of ash (the Almquist SHell) and is POSIX compliant"
HOMEPAGE="http://gondor.apana.org.au/~herbert/dash/"
SRC_URI=""

PROPERTIES="live"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="libedit static"

RDEPEND="!static? ( libedit? ( dev-libs/libedit ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	libedit? ( static? ( dev-libs/libedit[static-libs] ) )"

src_prepare() {
	# Use pkg-config for libedit linkage
	sed -i \
		-e "/LIBS/s:-ledit:\`$(tc-getPKG_CONFIG) --libs libedit $(usex static --static '')\`:" \
		configure.ac || die

	eapply_user
	eautoreconf
}

src_configure() {
	append-cppflags -DJOBS=$(usex libedit 1 0)
	use static && append-ldflags -static
	# Do not pass --enable-glob due to #443552.
	# Autotools use $LINENO as a proxy for extended debug support
	# (i.e. they're running bash), so disable that. #527644
	econf \
		--bindir="${EPREFIX}"/bin \
		--enable-fnmatch \
		--disable-lineno \
		$(use_with libedit)
}
