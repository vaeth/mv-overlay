# Copyright 2013-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
inherit eutils readme.gentoo-r1 systemd tmpfiles

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html
https://github.com/vaeth/squashmount/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

# These should really depend on USE-flags but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND="app-shells/runtitle
dev-perl/File-Which
!arm? ( !ia64? ( !sparc? ( dev-perl/String-ShellQuote ) ) )"

RDEPEND="!<sys-apps/openrc-0.13
	>=dev-lang/perl-5.22
	|| ( dev-perl/File-Which sys-apps/which )
	sys-fs/squashfs-tools
	!<sys-fs/unionfs-fuse-0.25
	!<app-portage/find_cruft-4.0.0
	${OPTIONAL_RDEPEND}"
#	>=dev-lang/perl-5.12
#	|| ( >=dev-lang/perl-5.10.1 >=virtual/perl-File-Path-2.6.5 )
#	|| ( >=dev-lang/perl-5.4.5 virtual/perl-File-Spec )
#	|| ( >=dev-lang/perl-5.10.1 >=virtual/perl-File-Temp-0.19 )
#	|| ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )
#	|| ( >=dev-lang/perl-5.9.3 virtual/perl-IO-Compress )
DEPEND=""

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="Please adapt /etc/squashmount.pl as well as
/etc/systemd/system/squashmount.service.d/timeout.conf to your needs.

Configure the mount point 'gentoo' only if you use sync-type = squashdelta.

For improved output use sys-fs/squashfs-tools from the mv overlay.

It is recommended to put into your zshrc the line:
alias squashmount='noglob squashmount'"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	default
}

src_install() {
	dobin bin/*
	dodoc README.md ChangeLog compress.txt demo.svg
	docompress -x "/usr/share/doc/${PF}/demo.svg"
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	dotmpfiles tmpfiles.d/*
	insinto /etc
	doins -r etc/revdep-rebuild etc/systemd
	exeinto /etc/portage/repo.postsync.d
	doexe etc/portage/repo.postsync.d/*
	insinto /usr/lib
	doins lib/*
	doins -r lib/find_cruft
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	readme.gentoo_create_doc
}

pkg_postinst() {
	if use arm || use ia64 || use sparc
	then	optfeature "improved output" 'dev-perl/String-ShellQuote'
	fi
	optfeature "user mounting" \
		'>=sys-fs/squashfuse-0.1.100 >=sys-fs/unionfs-fuse-0.25' \
		'>=sys-fs/squashfuse-0.1.100 sys-fs/funionfs'
	case " ${REPLACING_VERSIONS}" in
	*' '[0-9].*|*' '1[0-4].*|*' '15.[0-2].*|*' '15.3.0*)
		FORCE_PRINT_ELOG="true";;
	esac
	readme.gentoo_print_elog
	tmpfiles_process squashmount.conf
}
