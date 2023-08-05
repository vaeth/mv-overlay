# Copyright 2020-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="openrc init-files for systemd-tmpfiles from sys-apps/systemd"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/systemd"
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE=""

RDEPEND="
	!sys-apps/systemd-utils[tmpfiles]
	sys-apps/systemd
"
DEPEND=""

S="${WORKDIR}"

src_install() {
	newinitd "${FILESDIR}"/stmpfiles-dev.initd stmpfiles-dev
	newinitd "${FILESDIR}"/stmpfiles-setup.initd stmpfiles-setup
	newconfd "${FILESDIR}"/stmpfiles.confd stmpfiles-dev
	newconfd "${FILESDIR}"/stmpfiles.confd stmpfiles-setup
}

add_service() {
	elog "Auto-adding '${1}' service to your ${2} runlevel"
	mkdir -p -- "${EROOT}/etc/runlevels/${2}"
	ln -snf -- "${EPREFIX}/etc/init.d/${1}" "${EROOT}/etc/runlevels/${2}/${1}"
}

pkg_postinst() {
	if [[ -z $REPLACING_VERSIONS ]]; then
		add_service stmpfiles-dev sysinit
		add_service stmpfiles-setup boot
	fi
}
