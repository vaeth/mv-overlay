# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit readme.gentoo-r1

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

MAKE_ARGS=(
	"SHARE_DIR=${ED}/usr/share/zsh/site-contrib/${PN}"
	"DOC_DIR=${ED}/usr/share/doc/${PF}"
)

src_prepare() {
	grep -q 'local .*cdpath_dir' \
		"${S}/highlighters/main/main-highlighter.zsh" >/dev/null 2>&1 || \
		sed -i -e '/for cdpath_dir/ilocal cdpath_dir' \
			-- "${S}/highlighters/main/main-highlighter.zsh" || die
	eapply_user
}

src_compile() {
	emake "${MAKE_ARGS[@]}"
}

src_install() {
	emake "${MAKE_ARGS[@]}" install
	readme.gentoo_create_doc
}

src_test() {
	emake "${MAKE_ARGS[@]}" test
	emake "${MAKE_ARGS[@]}" perf
}

pkg_postinst() {
	readme.gentoo_print_elog
}
