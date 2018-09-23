# Copyright 1999-2018 Martin V\"ath and others
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LIVE=false
case ${PV} in
99999999*)
	LIVE=:;;
esac
if ${LIVE}
then	EGIT_REPO_URI="https://git.kernel.org/pub/scm/utils/dash/dash.git"
	WANT_LIBTOOL=none
	AT_NOELIBTOOLIZE=true
	inherit autotools git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI=""
else	# inherit versionator
	#MY_PV="$(get_version_component_range 1-3)"
	DEB_PATCH="" #"$(get_version_component_range 4)"
	#MY_P="${PN}-${MY_PV}"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
	SRC_URI="http://gondor.apana.org.au/~herbert/dash/files/${P}.tar.gz"
	if [ -n "${DEB_PATCH}" ]
	then	DEB_PF="${PN}_${MY_PV}-${DEB_PATCH}"
		SRC_URI=${SRC_URI}" mirror://debian/pool/main/d/dash/${DEB_PF}.diff.gz"
	fi
	#S=${WORKDIR}/${MY_P}
fi

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Descendant of the NetBSD ash. POSIX compliant except for multibyte characters"
HOMEPAGE="http://gondor.apana.org.au/~herbert/dash/"

LICENSE="BSD"
SLOT="0"
IUSE="libedit static vanilla"

RDEPEND="!static? ( libedit? ( dev-libs/libedit ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	libedit? ( static? ( dev-libs/libedit[static-libs] ) )"

src_prepare() {
	local c
	use vanilla || eapply "${FILESDIR}"/dumb-echo.patch
	if [ -n "${DEB_PATCH}" ]
	then	eapply "${WORKDIR}"/${DEB_PF}.diff
		eapply */debian/diff/*
	fi
	c='configure.ac configure'
	if ${LIVE}
	then	test -r configure || c=configure.ac
	else	c=configure
	fi
	# Use pkg-config for libedit linkage
	sed -i \
		-e "/LIBS/s:-ledit:\`$(tc-getPKG_CONFIG) --libs libedit $(usex static --static '')\`:" \
		${c} || die

	default
	! ${LIVE} || eautoreconf
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

src_install() {
	default
	[ -z "${DEB_PATCH}" ] || dodoc */debian/changelog
}
