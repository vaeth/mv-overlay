# Copyright 2016-2022 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RESTRICT="mirror"
inherit optfeature

DESCRIPTION="postsync hooks for portage to sync from git"
HOMEPAGE="https://github.com/vaeth/portage-postsyncd-mv/"
SRC_URI="https://github.com/vaeth/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~mips ~ppc ~ppc64 ~s390 x86"
IUSE=""

# These should really depend on USE-flags but must not by policy.
# Waiting for https://bugs.gentoo.org/show_bug.cgi?id=424283
OPTIONAL_RDEPEND="dev-perl/File-Which
dev-perl/String-ShellQuote"

RDEPEND=">=dev-lang/perl-5.6.1
!<app-portage/portage-utils-0.80_pre20190605
${OPTIONAL_RDEPEND}"
# || ( >=dev-lang/perl-5.6.1 >=virtual/perl-Getopt-Long-2.24 )

src_prepare() {
	use prefix || {
		sed -i \
				-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
				-- repo.postsync.d/[0-9]* || die
		sed -i \
			-e '1s"^#!/usr/bin/env "#!'"${EPREFIX}/usr/bin/"'"' \
				-- bin/* || die
	}
	default
}

src_install() {
	exeinto /usr/bin
	doexe bin/*
	dodoc README.md ChangeLog
	insinto /etc/portage/repo.postsync.d
	doins repo.postsync.d/*.sh repo.postsync.d/README
	docompress /etc/portage/repo.postsync.d/README
	insinto /usr/share/zsh/site-functions
	doins zsh/*
	exeinto /etc/portage/repo.postsync.d
	doexe repo.postsync.d/[0-9]*
}

pkg_postinst() {
	case " ${REPLACING_VERSIONS}" in
	*' '[01].*)
		ewarn "The previous versions of $PN had several bugs."
		ewarn 'It is recommended to remove from $PORTDIR/metadata the directories'
		ewarn '	dtd/ glsa/ news/ xml-schema/'
		ewarn 'as well as the directory $PORTDIR/local/timestamps'
		ewarn 'to make sure that these directories contain the correct content.'
		ewarn 'Moreover:';;
	esac
	case " ${REPLACING_VERSIONS}" in
	*' '[0-3].*)
		ewarn "The previous versions of $PN cleaned too aggressively."
		ewarn 'It is recommended to refetch all repositories.'
		ewarn 'Also remove the files'
		ewarn '	$PORTDIR/local/timestamp/git-gc.date'
		ewarn '	$REPO/.git/git-gc.date'
		ewarn 'where $PORTDIR and $REPO should be replaced by the paths to'
		ewarn 'your main repository or to each of your overlays, respectively.'
		ewarn 'Also note renaming of some configuration variables.'
		ewarn 'See the new ChangeLog file for details';;
	esac
	optfeature "faster execution" 'app-portage/eix'
}
