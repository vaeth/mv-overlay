# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit eutils

DESCRIPTION="Provide support for /etc/portage/bashrc.d and /etc/portage/package.cflags"
HOMEPAGE="https://github.com/vaeth/portage-bashrc-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="!<dev-util/ccache-3.2"

src_install() {
	dodoc NEWS README
	exeinto "/usr/share/doc/${PF}"
	doexe fix-portage-2.2.15
	docompress -x "/usr/share/doc/${PF}/fix-portage-2.2.15"
	insinto /etc/portage
	doins -r bashrc bashrc.d
	docompress /etc/portage/bashrc.d/README
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS}" in
	*' '[0-9].*|*' '1[0-2].*)
		ewarn "Remember to run /usr/share/doc/${PF}/fix-portage-2.2.15"
		ewarn "as the first command after upgrading to >=portage-2.2.15"
		ewarn "See NEWS for details";;
	esac
	optfeature "improved mask handling" app-portage/eix
	optfeature "output of expected emerge time" app-portage/portage-utils
	optfeature "detailed information output in title bar" app-shells/runtitle
	! test -d /var/cache/gpo || \
		ewarn "Obsolete /var/cache/gpo found. Please remove"
}
