# Copyright 2013-2021 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd toolchain-funcs linux-info

DESCRIPTION="Shows and sets processor power related values"
HOMEPAGE="https://www.kernel.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"
IUSE="nls"

# File collision w/ headers of the deprecated cpufrequtils
RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}
	virtual/os-headers
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}/cpupower-5.4-cflags.patch"
)

pkg_setup() {
	linux-info_pkg_setup
	KV_SRC=${KV_MAJOR}.${KV_MINOR}
	LINUX_SRC=linux-${KV_SRC}
	S="${WORKDIR}/${LINUX_SRC}"
}

src_unpack() {
	unpack "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${LINUX_SRC}.tar.xz"
}

src_configure() {
	export bindir="${EPREFIX}/usr/bin"
	export sbindir="${EPREFIX}/usr/sbin"
	export mandir="${EPREFIX}/usr/share/man"
	export includedir="${EPREFIX}/usr/include"
	export libdir="${EPREFIX}/usr/$(get_libdir)"
	export localedir="${EPREFIX}/usr/share/locale"
	export docdir="${EPREFIX}/usr/share/doc/${PF}"
	export confdir="${EPREFIX}/etc"
	export bash_completion_dir="${EPREFIX}/usr/share/bash-completion/completions"
	export V=1
	export NLS=$(usex nls true false)
}

src_compile() {
	myemakeargs=(
		AR="$(tc-getAR)"
		CC="$(tc-getCC)"
		LD="$(tc-getCC)"
		VERSION=${KV_FULL}
	)

	cd tools/power/cpupower || die
	emake "${myemakeargs[@]}"
}

src_install() {
	cd tools/power/cpupower || die
	emake "${myemakeargs[@]}" DESTDIR="${D}" install
	doheader lib/cpupower.h
	einstalldocs

	newconfd "${FILESDIR}"/conf.d-r2 cpupower
	newinitd "${FILESDIR}"/init.d-r4 cpupower

	systemd_dounit "${FILESDIR}"/cpupower-frequency-set.service
	systemd_install_serviced "${FILESDIR}"/cpupower-frequency-set.service.conf
}
