# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit readme.gentoo

case ${PV} in
99999999*)
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	RESTRICT="mirror"
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86";;
esac

DESCRIPTION="Fish shell like syntax highlighting for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting"

LICENSE="HPND"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add
. /usr/share/zsh/site-contrib/${PN}/zsh-syntax-highlighting.zsh
at the end of your ~/.zshrc
For testing, you can also execute the above command in your zsh."

src_prepare() {
	grep -q 'local .*cdpath_dir' \
		"${S}/highlighters/main/main-highlighter.zsh" >/dev/null 2>&1 || \
		sed -i -e '/for cdpath_dir/ilocal cdpath_dir' \
			-- "${S}/highlighters/main/main-highlighter.zsh" || die
	eapply_user
}

src_install() {
	dodoc *.md
	insinto /usr/share/zsh/site-contrib/${PN}
	doins *.zsh .revision-hash .version
	doins -r highlighters
	readme.gentoo_create_doc
}

pkg_postinst() {
	readme.gentoo_print_elog
}
