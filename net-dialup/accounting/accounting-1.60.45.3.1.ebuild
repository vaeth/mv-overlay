# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils rpm toolchain-funcs
RESTRICT="mirror"

MY_PN="smpppd"
case "${PV}" in
*.*.*.*)
	MY_PV="${PV#*.*.*.}"
	MY_PV=${PV%".${MY_PV}"}
	MY_P="${MY_PN}-${MY_PV}-${PV#*.*.*.}"
	;;
*)
	MY_PV="${PV}"
	MY_P="${MY_PN}-${MY_PV}"
	;;
esac
S="${WORKDIR}/${MY_PN}-${MY_PV}"
DESCRIPTION="Give statistics about dialup connections. Originally part of SuSE's smpppd"
HOMEPAGE="http://www.opensuse.org"
SRC_URI="http://download.opensuse.org/source/distribution/11.3/repo/oss/suse/src/${MY_P}.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

test -z "${ACCOUNTING_LOG}" && ACCOUNTING_LOG="/var/log/accounting.log"

DEPEND=">=net-dialup/ppp-2.4.4-r13"
RDEPEND="${DEPEND}"

CDIR="${S}/${MY_PN}"
DDIR="${S}/doc"

src_prepare() {
	printf '%s "%s"\n' '#define VERSION' "${MY_PV}" >"${CDIR}"/config.h
	sed -i -e's!^\(#define ACCOUNTING_LOG \).*$!\1"'"${ACCOUNTING_LOG}"'"!' \
		"${CDIR}"/defines.h
	sed -i -e's!/var/log/[^.]*\.log!'"${ACCOUNTING_LOG}"'!' \
		"${DDIR}"/accounting.1
	epatch_user
}

src_configure() {
	:
}

src_compile() {
	cd -- "${CDIR}"
	"$(tc-getCXX)" ${CXXFLAGS} ${LDFLAGS} -o accounting \
		accounting.cc utils.cc format.cc parse.cc tempus.cc filter.cc \
		|| die "compiling failed"
}

my_sedbin() {
	dodir "${2%/*}"
	sed -e "s!ACCOUNTING_LOG!${ACCOUNTING_LOG}!" -- "${1}" >"${D}/${2}"
	fperms 755 "${2}"
}

src_install() {
	dobin "${CDIR}/accounting"
	doman "${DDIR}/accounting.1"
	my_sedbin "${FILESDIR}"/ip-up.sh   /etc/ppp/ip-up.d/80-accounting.sh
	my_sedbin "${FILESDIR}"/ip-down.sh /etc/ppp/ip-down.d/10-accounting.sh
}

pkg_postinst() {
	ewarn "The accounting tool only interprets ${ACCOUNTING_LOG}"
	ewarn "This file is updated by scripts in /etc/ppp/ip-up.d and /etc/ppp/ip-down.d"
	ewarn "You might want to modify these scripts (e.g. add provider info)."
}
