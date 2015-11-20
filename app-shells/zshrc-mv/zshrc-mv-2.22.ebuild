# Copyright 1999-2015 Gentoo Foundation
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
KEYWORDS="~amd64 ~x86"
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
