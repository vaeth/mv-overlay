# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 optfeature

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="git://projects.archlinux.org/netctl.git"
	inherit git-2
	DEPEND="app-text/asciidoc"
else
	SRC_URI="https://sources.archlinux.org/other/packages/${PN}/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~x86"
fi

DESCRIPTION="Profile based network connection tool from Arch Linux"
HOMEPAGE="https://wiki.archlinux.org/index.php/Netctl
	https://www.archlinux.org/packages/core/any/netctl/
	https://projects.archlinux.org/netctl.git/"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

DEPEND+="
	virtual/pkgconfig
	sys-apps/systemd
"
RDEPEND="
	>=app-shells/bash-4.0
	>=net-dns/openresolv-3.5.4-r1
	sys-apps/iproute2
	sys-apps/systemd
	!<net-misc/dhcpcd-6.4.0
"

src_prepare() {
	sed -i -e "s:/usr/bin/ifplugd:/usr/sbin/ifplugd:" \
		"services/netctl-ifplugd@.service" || die
	default
}

src_compile() {
	:
}

src_install() {
	emake DESTDIR="${D}" SHELL=bash install
	dodoc AUTHORS NEWS README
	newbashcomp contrib/bash-completion netctl
	insinto /usr/share/zsh/site-functions
	newins contrib/zsh-completion _netctl
}

pkg_postinst() {
	optfeature "DHCP support" net-misc/dhcpcd ">=net-misc/dhcp-5.6.7[client]"
	optfeature "WPA support" net-wireless/wpa_supplicant
	optfeature "interactive assistant" dev-util/dialog
	optfeature "automatic connection" sys-apps/ifplugd
	optfeature "bonding support" net-misc/ifenslave
	optfeature "dialup support" net-dialup/ppp
}
