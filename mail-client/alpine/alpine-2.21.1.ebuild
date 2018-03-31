# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools toolchain-funcs vcs-snapshot

DESCRIPTION="alpine is an easy to use text-based based mail and news client"
HOMEPAGE="http://www.washington.edu/alpine/ http://repo.or.cz/alpine.git/"
GIT_COMMIT="672d6838a9babf2faeb9f79267525a4ab9d20b14"
SRC_URI="http://repo.or.cz/alpine.git/snapshot/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~alpha ~ia64 ~ppc ~sparc"
IUSE="debug doc ipv6 kerberos ldap libressl nls onlyalpine pam passfile smime spell ssl threads"

DEPEND="pam? ( virtual/pam )
	>=sys-libs/ncurses-5.1:0=
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	ldap? ( net-nds/openldap )
	kerberos? ( app-crypt/mit-krb5 )
	spell? ( app-text/aspell )
"
RDEPEND="${DEPEND}
	app-misc/mime-types
	!onlyalpine? ( !mail-client/pine )
	!<=net-mail/uw-imap-2004g
"

src_prepare() {
	sed -ie 's/AC_CHECK_LIB[^(]*([^,]*pam[^,]*,[^,]*,/AS_IF(['$(
		usex pam true false)'],/' -- "${S}"/configure.ac
	default
	eautoreconf
}

src_configure() {
	myconf=(
		--without-tcl
		--with-system-pinerc="${EPREFIX}"/etc/pine.conf
		--with-system-fixed-pinerc="${EPREFIX}"/etc/pine.conf.fixed
	)

	if use ssl; then
		myconf+=(
			--with-ssl-include-dir="${EPREFIX}"/usr/include/openssl
			--with-ssl-lib-dir="${EPREFIX}"/usr/$(get_libdir)
			--with-ssl-certs-dir="${EPREFIX}"/etc/ssl/certs
		)
	fi
	econf \
		$(use_enable debug) \
		$(use_with ldap) \
		$(use_with ssl) \
		$(use_with passfile passfile .pinepwd) \
		$(use_with kerberos krb5) \
		$(use_with threads pthread) \
		$(use_with spell interactive-spellcheck /usr/bin/aspell) \
		$(use_enable nls) \
		$(use_with ipv6) \
		$(use_with smime) \
		"${myconf[@]}"
}

src_compile() {
	emake AR=$(tc-getAR)
}

src_install() {
	if use onlyalpine ; then
		dobin alpine/alpine
		doman doc/man1/alpine.1
	else
		emake DESTDIR="${D}" install
		doman doc/man1/*.1
	fi

	dodoc NOTICE README*

	if use doc ; then
		dodoc doc/brochure.txt

		docinto html/tech-notes
		dodoc -r doc/tech-notes/*.html
		dodoc -r doc/tech-notes/*.txt
	fi
}
