# Copyright 1999-2024 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WANT_AUTOMAKE=none
WANT_LIBTOOL=none
inherit autotools flag-o-matic optfeature toolchain-funcs

DESCRIPTION="Excellent text file viewer, optionally with additional selection feature"
PATCHN="less-select"
PATCHV="2.16"
PATCHVER="661"
PATCHRUMP="${PATCHN}-${PATCHV}"
PATCHBALL="${PATCHRUMP}.tar.gz"
SELECTDIR="${WORKDIR}/${PATCHRUMP}"
HOMEPAGE="http://www.greenwoodsoftware.com/less/ https://github.com/vaeth/less-select"
SRC_URI="mirror+http://www.greenwoodsoftware.com/less/${P}.tar.gz
	less-select? ( https://github.com/vaeth/${PATCHN}/archive/v${PATCHV}.tar.gz -> ${PATCHBALL} )"
RESTRICT="mirror"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="+lesspipe +less-select pcre original-gentoo source test"
RESTRICT="test !test? ( test )"

DEPEND="
	>=app-misc/editor-wrapper-3
	>=sys-libs/ncurses-5.2:=
	pcre? ( dev-libs/libpcre2 )
"
RDEPEND="${DEPEND}
	less-select? ( dev-lang/perl )"
#		|| ( >=dev-lang/perl-5.10.1 >=virtual/perl-File-Temp-0.19 )
PDEPEND="lesspipe? ( app-text/lesspipe )"
BDEPEND="test? ( virtual/pkgconfig )"

PATCHES=(
	"${FILESDIR}"/${PN}-643-lesstest-pkg-config.patch
)

pkg_setup() {
	if use source && ! use less-select
	then	ewarn 'ignoring USE=source without USE=less-select'
	fi
}

src_prepare() {
	if use less-select
	then	eapply "${SELECTDIR}/patches/less-${PATCHVER}-select.patch"
		"${SELECTDIR}"/after-patch || die "${SELECTDIR}/after-patch failed"
		sed -i -e 's|\([^a-zA-Z]\)/etc/less-select-key.bin|\1'"${EPREFIX}"'/etc/less/select-key.bin|g' \
			"${SELECTDIR}/bin/less-select" || die
	fi

	default
	# Upstream uses unpatched autoconf-2.69, which breaks with clang-16.
	# https://bugs.gentoo.org/870412
	eautoreconf
}

src_configure() {
	append-lfs-flags # bug #896316

	local myeconfargs=(
		--with-regex=$(usex pcre pcre2 posix)
		--with-editor="${EPREFIX}"/usr/libexec/editor
	)
	econf "${myeconfargs[@]}"
}

src_compile() {
	default
	if use less-select
	then	./lesskey -o normal-key.bin "${SELECTDIR}/keys/less-normal-key.src" || die
		./lesskey -o select-key.bin "${SELECTDIR}/keys/less-select-key.src" || die
	fi
}

src_test() {
	emake check VERBOSE=1 CC="$(tc-getCC)" PKG_CONFIG="$(tc-getPKG_CONFIG)"
}

src_install() {
	local a
	default

	keepdir /usr/lib/lessfilter.d
	keepdir /etc/lessfilter.d

	newbin "${FILESDIR}"/lesspipe-r4.sh lesspipe

	if use original-gentoo
	then	a="-R -M --shift 5"
	else	a="-sFRiMX --shift 5"
	fi
	printf '%s\n' \
		'LESSOPEN="|lesspipe'$(usex lesspipe .sh)' %s"' \
		"LESS=\"${a}\"" \
		>70less || die
	doenvd 70less

	if use less-select
	then	newdoc "${SELECTDIR}"/README.md README.less-select
		dobin "${SELECTDIR}/bin/"*
		insinto /etc/less
		doins select-key.bin normal-key.bin
		if use source
		then	newins "${SELECTDIR}/keys/less-select-key.src" select-key.src
			newins "${SELECTDIR}/keys/less-normal-key.src" normal-key.src
		fi
	fi
}

pkg_preinst() {
	use lesspipe || optfeature "Colorized output support" dev-python/pygments
}
