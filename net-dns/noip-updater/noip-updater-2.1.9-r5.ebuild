# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit readme.gentoo-r1 systemd toolchain-funcs user

MY_P=${P/-updater/}
DESCRIPTION="no-ip.com dynamic DNS updater"
HOMEPAGE="http://www.no-ip.com"
SRC_URI="http://www.no-ip.com/client/linux/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ia64 ~mips ~ppc ppc64 sparc x86"
IUSE="ezipupd"

S=${WORKDIR}/${MY_P}

DOC_CONTENTS="
	Configuration can be done manually via /usr/sbin/noip2 -C or
	by using this ebuild's config option.
"

src_prepare() {
	eapply "${FILESDIR}"/noip-2.1.9-flags.patch
	eapply "${FILESDIR}"/noip-2.1.9-daemon.patch
	local sedarg
	sedarg=(
		-e "s:\(#define CONFIG_FILEPATH\).*:\1 \"/etc\":"
		-e "s:\(#define CONFIG_FILENAME\).*:\1 \"/etc/no-ip2.conf\":"
	)
	! use ezipupd || sedarg+=(
		-e "s:\"nobody\":\"ez-ipupd\":g"
	)
	sed -i "${sedarg[@]}" noip2.c || die "sed failed"
	default
}

src_compile() {
	emake \
		CC=$(tc-getCC) \
		PREFIX=/usr \
		CONFDIR=/etc
}

src_install() {
	dosbin noip2
	dodoc README.FIRST
	newinitd "${FILESDIR}"/noip2.start noip
	systemd_dounit "${FILESDIR}"/noip.service
	readme.gentoo_create_doc
}

pkg_preinst() {
	use ezipupd && ! use prefix || return 0
	enewgroup ez-ipupd
	enewuser ez-ipupd -1 -1 /var/cache/ez-ipupdate ez-ipupd
	if test -d /var/cache/ez-ipupdate
	then	chmod 750 /var/cache/ez-ipupdate
		chown ez-ipupd:ez-ipupd /var/cache/ez-ipupdate
	fi
}

pkg_postinst() {
	readme.gentoo_print_elog
}

pkg_config() {
	cd /tmp
	einfo "Answer the following questions."
	noip2 -C || die
}
