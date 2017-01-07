# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit eutils readme.gentoo-r1 user systemd

DESCRIPTION="script to schedule jobs in a multiuser multitasking environment"
HOMEPAGE="https://github.com/vaeth/schedule/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="!<sys-apps/openrc-0.13
	>=dev-lang/perl-5.12"
#	|| ( >=dev-lang/perl-5.10.1 >=virtual/perl-version-0.77 )
#	|| ( >=dev-lang/perl-5.1 virtual/perl-File-Path )
#	|| ( >=dev-lang/perl-5.9.4 virtual/perl-File-Spec-3.0 )
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )
#	|| ( >=dev-lang/perl-5.6.0 >=virtual/perl-IO-1.190.0 )
#	|| ( >=dev-lang/perl-5.9.4 virtual/perl-Digest-SHA) # for encryption
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="It is recommended to put a lengthy passphrase into the first line
of /etc/schedule.password and to change permission so that only users allowed
to access the system schedule-server can read it.

You might want to adapt /etc/conf.d/schedule to your needs.
If you use systemd, you might want to override schedule.service locally in
/etc/systemd/system to adapt it to your needs."

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-e 's"^/usr/share/schedule"${EPREFIX}/usr/share/${PN}"' \
		-e '/^use FindBin;/,/^\}$/d' \
		-- bin/* || die
	eapply_user
}

src_install() {
	dobin bin/*
	dodoc README ChangeLog
	insinto /usr
	doins -r share
	doinitd openrc/init.d/*
	doconfd openrc/conf.d/*
	systemd_dounit systemd/system/*
	doenvd env.d/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	insinto /etc
	(
		umask 027
		: >"${ED}/etc/schedule.password"
	)
	readme.gentoo_create_doc
}

generate_password() (
	umask 027
	for i in {1..50}
	do	printf "%s" "${RANDOM}"
	done >"${EPREFIX}/etc/schedule.password"
)

pkg_postinst() {
	optfeature "colored output" '>=dev-lang/perl-5.14' 'virtual/perl-Term-ANSIColor'
	optfeature "encryption support" 'dev-perl/Crypt-Rijndael'
	if ! use prefix
	then	enewgroup schedule
		enewuser schedule -1 -1 -1 schedule
	fi
	if ! test -s "${EPREFIX}/etc/schedule.password"
	then	if generate_password
		then	ewarn "You should fill ${EPREFIX}/etc/schedule.password with a random password:"
			ewarn "the current random value is not necessarily cryptographically strong."
			chown 'schedule:schedule' -- "${EPREFIX}/etc/schedule.password" || \
				ewarn "failed to set permissions for ${EPREFIX}/etc/schedule.password"
		else	ewarn "failed to generate ${EPREFIX}/etc/schedule.password"
		fi
	fi
	readme.gentoo_print_elog
}
