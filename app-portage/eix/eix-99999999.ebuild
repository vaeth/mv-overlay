# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="git://github.com/vaeth/${PN}.git"
WANT_LIBTOOL=none
PLOCALES="de ru"
inherit autotools bash-completion-r1 git-r3 l10n systemd

DESCRIPTION="Search and query ebuilds, portage incl. local settings, ext. overlays and more"
HOMEPAGE="https://github.com/vaeth/eix/"
SRC_URI=""
PROPERTIES="live"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug +dep doc nls optimization +required-use security strong-optimization strong-security sqlite swap-remote tools"

BOTHDEPEND="sqlite? ( >=dev-db/sqlite-3 )
	nls? ( virtual/libintl )"
RDEPEND="${BOTHDEPEND}
	>=app-shells/push-2.0
	>=app-shells/quoter-3.0"
DEPEND="${BOTHDEPEND}
	>=sys-devel/gettext-0.19.6"

pkg_setup() {
	case " ${REPLACING_VERSIONS}" in
	*\ 0.[0-9].*|*\ 0.1[0-9].*|*\ 0.2[0-4].*|*\ 0.25.0*)
		local eixcache="${EROOT}/var/cache/${PN}"
		test -f "${eixcache}" && rm -f -- "${eixcache}";;
	esac
}

src_prepare() {
	sed -i -e "s'/'${EPREFIX}/'" -- "${S}"/tmpfiles.d/eix.conf || die
	eapply_user
	eautopoint
	eautoreconf
}

src_configure() {
	econf $(use_with sqlite) $(use_with doc extra-doc) \
		$(use_enable nls) $(use_enable tools separate-tools) \
		$(use_enable security) $(use_enable optimization) \
		$(use_enable strong-security) \
		$(use_enable strong-optimization) $(use_enable debug debugging) \
		$(use_enable swap-remote) \
		$(use_with prefix always-accept-keywords) \
		$(use_with dep dep-default) \
		$(use_with required-use required-use-default) \
		--with-zsh-completion \
		--with-portage-rootpath="${ROOTPATH}" \
		--with-eprefix-default="${EPREFIX}"
}

src_install() {
	default
	dobashcomp bash/eix
	systemd_dotmpfilesd tmpfiles.d/eix.conf
}

pkg_postinst() {
	test -d "${EROOT}var/cache/${PN}" || {
		mkdir "${EROOT}var/cache/${PN}"
		use prefix || chown portage:portage "${EROOT}var/cache/${PN}"
	}
	local obs="${EROOT}var/cache/eix.previous"
	! test -f "${obs}" || ewarn "Found obsolete ${obs}, please remove it"
}

pkg_postrm() {
	[ -n "${REPLACED_BY_VERSION}" ] || rm -rf -- "${EROOT}var/cache/${PN}"
}
