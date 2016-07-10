# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( jython2_7 pypy python2_7 )
EGIT_REPO_URI="git://github.com/google/styleguide.git"
inherit elisp-common git-r3 python-single-r1
RESTRICT="mirror"

DESCRIPTION="The google styleguide together with cpplint and an emacs file"
HOMEPAGE="https://github.com/google/styleguide"
SRC_URI=""
LICENSE="CC-BY-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="emacs"

EMACSNAME="google-c-style"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
COMMON="emacs? ( virtual/emacs )"
DEPEND="${COMMON}"
RDEPEND="${PYTHON_DEPS}
	${COMMON}"

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
	eapply_user
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
