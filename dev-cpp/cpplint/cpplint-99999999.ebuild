# Copyright 2012-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( pypy3 python{2_7,3_{6,7,8,9}} )
EGIT_REPO_URI="https://github.com/google/styleguide.git"
inherit elisp-common git-r3 python-single-r1
RESTRICT="mirror"

DESCRIPTION="The google styleguide together with cpplint and an emacs file"
HOMEPAGE="https://github.com/google/styleguide"
SRC_URI=""
LICENSE="CC-BY-3.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="emacs"

EMACSNAME="google-c-style"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
COMMON="emacs? ( virtual/emacs )"
BDEPEND="${COMMON}"
RDEPEND="${PYTHON_DEPS}
	${COMMON}"

PATCHES=("$FILESDIR"/"${PN}"-python3.patch)

src_prepare() {
	if use emacs
	then	mkdir sitefile
		cat >"sitefile/50${EMACSNAME}-gentoo.el" <<EOF
(add-to-list 'load-path "@SITELISP@")
(autoload 'google-set-c-style "${EMACSNAME}"
  "Set the current buffer's c-style to Google C/C++ Programming
  Style. Meant to be added to \`c-mode-common-hook'." t)
(add-hook 'c-mode-common-hook 'google-set-c-style)

; If you want the RETURN key to go to the next line and space over
; to the right place, uncomment the following line
;(add-hook 'c-mode-common-hook 'google-make-newline-indent)
EOF
	fi
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
		-- "${S}/${PN}/${PN}.py" || die
	python_fix_shebang "${S}"
	default
}

src_compile() {
	if use emacs
	then	elisp-compile *.el || die
	fi
}

src_install() {
	dobin ${PN}/cpplint.py
	dodoc ${PN}/README README.md
	if use emacs
	then	elisp-install "${EMACSNAME}" "${EMACSNAME}".{el,elc} || die
		elisp-site-file-install "sitefile/50${EMACSNAME}-gentoo.el" "${EMACSNAME}" || die
	fi
	insinto /usr/share/vim/vimfiles/syntax
	doins *.vim
	insinto /usr/share/doc/${PF}/html
	doins -r *.css *.html *.png *.xsl include
}

pkg_postinst() {
	elisp-site-regen
}

pkg_postrm() {
	elisp-site-regen
}
