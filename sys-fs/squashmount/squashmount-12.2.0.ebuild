# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit eutils readme.gentoo systemd

DESCRIPTION="Keep directories compressed with squashfs. Useful for portage tree, texmf-dist"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-465367.html
https://github.com/vaeth/squashmount/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="!<sys-apps/openrc-0.13
	>=app-shells/runtitle-2.3
	>=dev-lang/perl-5.12
	|| ( dev-perl/File-Which sys-apps/which )
	sys-fs/squashfs-tools
	!<sys-fs/unionfs-fuse-0.25"
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

For improved output use squasfs-tools from the mv overlay.

It is recommended to put into your zshrc the line:
alias squashmount='noglob squashmount'"

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env perl$"#!'"${EPREFIX}/usr/bin/perl"'"' \
		-- bin/* || die
	eapply_user
}

src_install() {
	dobin bin/*
	dodoc README ChangeLog compress.txt etc/squashmount.pl
	doinitd openrc/init.d/*
	systemd_dounit systemd/system/*
	systemd_dotmpfilesd tmpfiles.d/*
	insinto /etc
	doins -r etc/*
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	readme.gentoo_create_doc
}

pkg_postinst() {
	optfeature "status bar support" 'app-shells/runtitle'
	optfeature "improved compatibility and security" 'dev-perl/File-Which'
	optfeature "colored output" '>=dev-lang/perl-5.14' 'virtual/perl-Term-ANSIColor'
	case " ${REPLACING_VERSIONS}" in
	' '[0-7].*|' '8.[0-6]*|' '8.7.[0-4]*)
		FORCE_PRINT_ELOG="true";;
	esac
	readme.gentoo_print_elog
}
