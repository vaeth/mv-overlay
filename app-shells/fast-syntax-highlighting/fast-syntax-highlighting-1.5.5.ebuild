# Copyright 2011-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

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
	EGIT_COMMIT="3361bb62d66540eda6dfa23f3df34125c27d420f"
	SRC_URI="https://github.com/zdharma/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
*)
	myPN=$(ver_rs 2 '')
	SRC_URI="https://github.com/zdharma/${PN}/archive/v${myPN}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${myPN}";;
esac

DESCRIPTION="Optimized and extended zsh-syntax-highlighting"
HOMEPAGE="https://github.com/zdharma/fast-syntax-highlighting/"

LICENSE="HPND"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

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
