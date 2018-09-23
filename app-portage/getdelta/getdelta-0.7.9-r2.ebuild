# Copyright 1999-2018 Martin V\"ath and others
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit readme.gentoo-r1

DESCRIPTION="dynamic deltup client"
HOMEPAGE="http://linux01.gwdg.de/~nlissne/"
SRC_URI="http://linux01.gwdg.de/~nlissne/${PN}-0.7.8.tar.bz2"
SLOT="0"
IUSE=""
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~sparc ~x86"
S="${WORKDIR}"

RDEPEND="app-portage/deltup
	dev-util/bdelta"

src_prepare() {
	eapply "${FILESDIR}/eapi2.patch"
	sed -i -e "s:/bin/sh:/bin/bash:" getdelta.sh || die
	default
}

src_install() {
	local DISABLE_AUTOFORMATTING DOC_CONTENTS
	dobin "${WORKDIR}"/getdelta.sh
	DISABLE_AUTOFORMATTING="true"
	DOC_CONTENTS="You need to put
FETCHCOMMAND=\"/usr/bin/getdelta.sh \\\"\\\${URI}\\\" \\\"\\\${FILE}\\\"\"
into your /etc/make.conf to make use of getdelta"
	readme.gentoo_create_doc
}

pkg_postinst() {
	local a b
	# make sure permissions are ok
	a="${EROOT}"/var/log/getdelta.log
	b="${EROOT}"/etc/deltup
	test -f "${a}" || touch -- "${a}"
	mkdir -p -- "${b}"
	use prefix || chown -R portage:portage -- "${a}" "${b}"
	chmod -R ug+rwX -- "${a}" "${b}"
	readme.gentoo_print_elog
}
