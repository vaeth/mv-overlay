# Copyright 2016-2024 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"

DESCRIPTION="A grub.cfg library/example for GRUB2"
HOMEPAGE="https://github.com/vaeth/grub-cfg-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ppc ppc64 ~riscv sparc x86"
IUSE=""

src_install() {
	insinto /boot/grub
	doins boot/grub/grub-mv.cfg
	newins boot/grub/grub.cfg grub-mv-example.cfg
	dodoc README.md
}
