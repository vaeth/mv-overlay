# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit eutils

DESCRIPTION="A zshrc file initializing zsh specific interactive features"
HOMEPAGE="https://github.com/vaeth/zshrc-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
RDEPEND="!app-shells/auto-fu-zsh[kill-line(-)]"

src_install() {
	dodoc README
	insinto /etc/zsh
	doins zshrc
}

pkg_postinst() {
	optfeature "automagic completion" '>=app-shells/auto-fu-zsh-0.0.1.13'
	optfeature "syntax highlighting" 'app-shells/zsh-syntax-highlighting'
	optfeature "a nice prompt" 'app-shells/set_prompt'
	optfeature "nice directory colors" 'app-shells/termcolors-mv'
}
