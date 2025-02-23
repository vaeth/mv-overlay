# Copyright 2013-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A zshrc file initializing zsh specific interactive features"
HOMEPAGE="https://github.com/vaeth/zshrc-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-4.0"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# These should really depend on USE-flags but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND=">=app-shells/auto-fu-zsh-0.0.1.12_p0
>=app-shells/set_prompt-3.0.0
app-shells/termcolors-mv
app-shells/zsh-autosuggestions
|| ( app-shells/fast-syntax-highlighting app-shells/zsh-syntax-highlighting )"

RDEPEND="!app-shells/auto-fu-zsh[kill-line(-)]
	${OPTIONAL_RDEPEND}"

src_install() {
	dodoc README.md
	insinto /etc/zsh
	doins zshrc
}
