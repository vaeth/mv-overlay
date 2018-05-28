# Copyright 2011-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit readme.gentoo-r1

RESTRICT="mirror"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/zdharma/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*alpha*)
	EGIT_COMMIT="7bec6e57829e1020165a03371ea38a4adae7176d"
	SRC_URI="https://github.com/zdharma/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
*)
	SRC_URI="https://github.com/zdharma/${PN}/archive/${PV/_rc/-rc}.tar.gz -> ${P}.tar.gz";;
esac

DESCRIPTION="Optimized and extended zsh-syntax-highlighting"
HOMEPAGE="https://github.com/zdharma/fast-syntax-highlighting/"

LICENSE="HPND"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add
. /usr/share/zsh/site-contrib/${PN}/fast-syntax-highlighting.plugin.zsh
at the end of your ~/.zshrc
For testing, you can also execute the above command in your zsh."

MAKE_ARGS=(
	"SHARE_DIR=${ED}/usr/share/zsh/site-contrib/${PN}"
	"DOC_DIR=${ED}/usr/share/doc/${PF}"
)

src_install() {
	local DISABLE_AUTOFORMATTING DOC_CONTENTS dir
	dir="/usr/share/zsh/site-contrib/${PN}"
	DISABLE_AUTOFORMATTING="true"
	DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add
. ${EPREFIX}${dir}/fast-syntax-highlighting.plugin.zsh"'
at the end of your ~/.zshrc
For testing, you can also execute the above command in your zsh.'
	readme.gentoo_create_doc
	insinto "${dir}"
	doins -r *
}

pkg_postinst() {
	readme.gentoo_print_elog
}
