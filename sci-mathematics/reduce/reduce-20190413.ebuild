# Copyright 1999-2019 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
inherit elisp-common flag-o-matic

DESCRIPTION="A general-purpose computer algebra system"
HOMEPAGE="http://reduce-algebra.sourceforge.net/
	http://reduce-algebra.com/"
IUSE="doc emacs gnuplot tinfo X"
PVyear=${PV%????}
PVday=${PV#??????}
PVmonth=${PV#????}
PVmonth=${PVmonth%??}
mPV="${PVyear}-${PVmonth}-${PVday}"
#TARBALL="${PN}-src-${mPV}"
TARBALL="Reduce-svn4961-src"
SRC_URI="mirror://sourceforge/${PN}-algebra/snapshot_${mPV}/${TARBALL}.tar.gz"
LICENSE="BSD-2 X? ( LGPL-2.1 )"
SLOT="0"
KEYWORDS="" # The ebuild is currently broken
S="${WORKDIR}/${TARBALL}"

RDEPEND="X? ( x11-libs/libXrandr
		x11-libs/libXcursor
		x11-libs/libXft )
	sys-libs/ncurses[tinfo=]
	gnuplot? ( sci-visualization/gnuplot )
	emacs? ( virtual/emacs )"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e '2iecho gentoo; exit' -- "${S}"/scripts/findos.sh
	# sed -i -e 's/\${l}/"\${l}"/g' -- "${S}"/scripts/make.sh
	sed -i -e 's/static char unmapTable/static unsigned char unmapTable/' \
		-- "${S}"/csl/fox/src/FXShowMath.cpp
	# This is currently only a hack for testing; a proper fix needs patching
	! use tinfo || append-ldflags -ltinfo
	default
}

src_configure() {
	# If you pass --prefix to this damn configure,
	# make (not make install!) will try to install stuff
	# into the live file system => sandbox violation
	# Therefore, I cannot use econf here
	# Also, make calls configure in maintainer mode in subdirs *by design*
	# The trunk sucks less => WONTFIX until the next release
	./configure --with-csl $(use_with X gui)
	# psl build requires Internet connection at build time
	# we cannot support it
}

src_compile() {
	emake -j1 STRIP=true

	pushd cslbuild/*/csl/reduce.doc > /dev/null
	rm -f *.txt *.tex
	popd > /dev/null

	if use emacs; then
		einfo "Compiling emacs lisp files"
		elisp-compile generic/emacs/*.el || die "elisp-compile failed"
	fi
}

src_test() {
	emake -j1 testall || die "emake testall failed"
}

src_install() {
	local lib="$(get_libdir)"
	dodoc README BUILDING DEPENDENCY_TRACKING
	pushd bin > /dev/null
	cp "${FILESDIR}"/redcsl "${FILESDIR}"/csl .
	sed -e "s/lib/${lib}/" -i redcsl
	sed -e "s/lib/${lib}/" -i csl
	exeinto /usr/bin
	doexe redcsl csl
	popd > /dev/null

	pushd cslbuild/*/csl > /dev/null
	exeinto /usr/${lib}/${PN}
	doexe reduce csl
	insinto /usr/$(get_libdir)/${PN}
	doins reduce.img csl.img
	insinto /usr/share/${PN}
	doins -r ${PN}.doc
	mv -- "${ED}"usr/share/${PN}/${PN}.doc "${ED}"usr/share/${PN}/doc
	dosym ../../share/${PN}/doc /usr/${lib}/${PN}/${PN}.doc
	if use X; then
		doins -r ${PN}.fonts
		mv -- "${ED}"usr/share/${PN}/${PN}.fonts "${ED}"usr/share/${PN}/fonts
		dosym ../../share/${PN}/fonts /usr/${lib}/${PN}/${PN}.fonts
	fi
	popd > /dev/null

	if use doc; then
		insinto /usr/share/doc/${PF}
		doins doc/util/r38.pdf
	fi

	if use emacs; then
		pushd generic/emacs > /dev/null
		elisp-install ${PN} *.el *.elc || die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/64${PN}-gentoo.el"
		popd > /dev/null
	fi
}
