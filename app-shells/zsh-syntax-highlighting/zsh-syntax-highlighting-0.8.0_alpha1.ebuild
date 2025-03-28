# Copyright 2011-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit readme.gentoo-r1

RESTRICT="mirror"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/zsh-users/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
0.8.0_alpha1)
	my_PV=${PV/_alpha/-alpha}-pre-redrawhook
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${my_PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${my_PV}";;
	#SRC_URI="https://github.com/zsh-users/${PN}/archive/${PV/_alpha/-alpha}-pre-redrawhook.tar.gz -> ${P}.tar.gz";;
*beta*)
	EGIT_COMMIT="02a37dd919dc48e0821186e5f20e78bd0215f86a"
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
*)
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${PV/_rc/-rc}.tar.gz -> ${P}.tar.gz";;
esac

DESCRIPTION="Fish shell like syntax highlighting for zsh"
HOMEPAGE="https://github.com/zsh-users/zsh-syntax-highlighting/"

LICENSE="HPND"
SLOT="0"
IUSE=""

RDEPEND="app-shells/zsh"
DEPEND=""

MAKE_ARGS=(
	"SHARE_DIR=${ED}/usr/share/zsh/site-contrib/${PN}"
	"DOC_DIR=${ED}/usr/share/doc/${PF}"
)

src_prepare() {
	grep -q 'local .*cdpath_dir' \
		"${S}/highlighters/main/main-highlighter.zsh" >/dev/null 2>&1 || \
		sed -i -e '/for cdpath_dir/ilocal cdpath_dir' \
			-- "${S}/highlighters/main/main-highlighter.zsh" || die
	default
}

src_compile() {
	emake "${MAKE_ARGS[@]}"
}

src_install() {
	local DISABLE_AUTOFORMATTING DOC_CONTENTS
	emake "${MAKE_ARGS[@]}" install
	DISABLE_AUTOFORMATTING="true"
	DOC_CONTENTS="In order to use ${CATEGORY}/${PN} add
. /usr/share/zsh/site-contrib/${PN}/zsh-syntax-highlighting.zsh
at the end of your ~/.zshrc
For testing, you can also execute the above command in your zsh."
	readme.gentoo_create_doc
}

src_test() {
	emake "${MAKE_ARGS[@]}" test
	emake "${MAKE_ARGS[@]}" perf
}

pkg_postinst() {
	readme.gentoo_print_elog
}
