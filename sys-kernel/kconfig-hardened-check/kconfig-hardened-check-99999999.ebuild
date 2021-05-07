# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9,10} )

inherit distutils-r1

DESCRIPTION="A script for checking the hardening options in the Linux kernel config"
HOMEPAGE="https://github.com/a13xp0p0v/kconfig-hardened-check"

case ${PV} in
99999999)
	inherit git-r3
	EGIT_REPO_URI="https://github.com/a13xp0p0v/kconfig-hardened-check"
;;
*)
	SRC_URI="https://github.com/a13xp0p0v/kconfig-hardened-check/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
	RESTRICT="mirror"
;;
esac

IUSE=""
LICENSE="GPL-3"
SLOT="0"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="${RDEPEND}"

src_install() {
	distutils-r1_src_install
	dodoc -r "${PN//-/_}"/config_files/ README.md
}
