# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
PLOCALES="de ru"
inherit bash-completion-r1 l10n meson_optional tmpfiles

DESCRIPTION="Search and query ebuilds"
HOMEPAGE="https://github.com/vaeth/eix/"
SRC_URI="https://github.com/vaeth/eix/releases/download/v${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug +dep doc +meson nls optimization +required-use security strong-optimization strong-security sqlite swap-remote tools"

BOTHDEPEND="nls? ( virtual/libintl )
	sqlite? ( >=dev-db/sqlite-3:= )"
RDEPEND="${BOTHDEPEND}
	>=app-shells/push-2.0-r2
	>=app-shells/quoter-3.0-r2"
DEPEND="${BOTHDEPEND}
	meson? (
		>=dev-util/meson-0.41.0
		>=dev-util/ninja-1.7.2
	)
	app-arch/xz-utils
	nls? ( sys-devel/gettext )"

pkg_setup() {
	# remove stale cache file to prevent collisions
	local old_cache="${EROOT}var/cache/${PN}"
	test -f "${old_cache}" && rm -f -- "${old_cache}"
}

src_prepare() {
	sed -i -e "s'/'${EPREFIX}/'" -- "${S}"/tmpfiles.d/eix.conf || die
	eapply_user
}

src_configure() {
	local emesonargs
	emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${P}" \
		-Dhtmldir="${EPREFIX}/usr/share/doc/${P}/html" \
		-Dsqlite=$(usex sqlite true false) \
		-Dextra-doc=$(usex doc true false) \
		-Dnls=$(usex nls true false) \
		-Dseparate-tools=$(usex tools true false) \
		-Dsecurity=$(usex security true false) \
		-Doptimization=$(usex optimization true false) \
		-Dstrong-secutiry=$(usex strong-security true false) \
		-Dstrong-optimization=$(usex strong-optimization true false) \
		-Ddebugging=$(usex debug true false) \
		-Dswap-remote=$(usex swap-remote true false) \
		-Dalways-accept-keywords=$(usex prefix true false) \
		-Ddep-default=$(usex dep true false) \
		-Drequired-use-default=$(usex required-use true false) \
		-Dzsh-completion="${EPREFIX}/usr/share/zsh/site-functions" \
		-Dportage-rootpath="${ROOTPATH}" \
		-Deprefix-default="${EPREFIX}"
	)
	if use meson; then
		meson_src_configure
	else
		econf \
		$(use_with sqlite) \
		$(use_with doc extra-doc) \
		$(use_enable nls) \
		$(use_enable tools separate-tools) \
		$(use_enable security) \
		$(use_enable optimization) \
		$(use_enable strong-security) \
		$(use_enable strong-optimization) \
		$(use_enable debug debugging) \
		$(use_enable swap-remote) \
		$(use_with prefix always-accept-keywords) \
		$(use_with dep dep-default) \
		$(use_with required-use required-use-default) \
		--with-zsh-completion \
		--with-portage-rootpath="${ROOTPATH}" \
		--with-eprefix-default="${EPREFIX}"
	fi
}

src_compile() {
	if use meson; then
		meson_src_compile
	else
		default
	fi
}

src_test() {
	if use meson; then
		meson_src_test
	else
		default
	fi
}

src_install() {
	if use meson; then
		meson_src_install
	else
		default
	fi
	dobashcomp bash/eix
	dotmpfiles tmpfiles.d/eix.conf
}

pkg_postinst() {
	local obs="${EROOT}var/cache/eix.previous"
	if test -f "${obs}"; then
		ewarn "Found obsolete ${obs}, please remove it"
	fi
	tmpfiles_process eix.conf
}

pkg_postrm() {
	if [ -z "${REPLACED_BY_VERSION}" ]; then
		rm -rf -- "${EROOT}var/cache/${PN}"
	fi
}
