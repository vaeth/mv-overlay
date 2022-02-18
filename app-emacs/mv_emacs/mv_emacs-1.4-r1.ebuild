# Copyright 2012-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit elisp-common

DESCRIPTION="(X)Emacs extensions: block support, macrorecorder, verify change"
HOMEPAGE="https://github.com/vaeth/mv_emacs/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x86-solaris"
IUSE=""

BDEPEND="app-editors/emacs"
RDEPEND=${DEPEND}

src_unpack() {
	default
	cd "${S}"
	mkdir sitefile
	cat >"sitefile/50${PN}-gentoo.el" <<EOF
(add-to-list 'load-path "@SITELISP@")
(load "mv_emacs-autoloads")
EOF
}

src_compile() {
	elisp-make-autoload-file || die
	elisp-compile *.el || die
}

src_install() {
	dodoc README.md
	elisp-install "${PN}" *.el *.elc || die
	elisp-site-file-install "sitefile/50${PN}-gentoo.el" || die
}

pkg_postinst() {
	elisp-site-regen
}

pkg_postrm() {
	elisp-site-regen
}
