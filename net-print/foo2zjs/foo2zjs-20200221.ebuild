# Copyright 1999-2020 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs eutils

DESCRIPTION="Support for printing to ZjStream-based printers"
HOMEPAGE="http://foo2zjs.rkkda.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="foomaticdb test"

PATCHES=(
	"${FILESDIR}/foreground.patch"
	"${FILESDIR}/usbbackend.patch"
	"${FILESDIR}/udev.patch"
)

RESTRICT="bindist !test? ( test )"

RDEPEND="net-print/cups
	foomaticdb? ( net-print/foomatic-db-engine )
	>=net-print/cups-filters-1.0.43-r1[foomatic]
	virtual/udev"
DEPEND="${RDEPEND}
	app-arch/unzip
	app-editors/vim
	sys-apps/ed
	sys-devel/bc
	test? ( sys-process/time )"

SRC_URI="https://dev.gentoo.org/~zerochaos/distfiles/${P}.tar.xz"

src_prepare() {
	# Prevent an access violation.
	sed -e "s~/etc~${D}/etc~g" -i Makefile || die
	sed -e "s~/etc~${D}/etc~g" -i hplj1000 || die

	# Prevent an access violation, do not create symlinks on live file system
	# during installation.
	sed -e 's/ install-filter / /g' -i Makefile || die

	# Prevent an access violation, do not remove files from live filesystem
	# during make install
	sed -e '/rm .*LIBUDEVDIR)\//d' -i Makefile || die
	sed -e '/rm .*lib\/udev\/rules.d\//d' -i hplj1000 || die

	default
}

src_compile() {
	MAKEOPTS=-j1 CC="$(tc-getCC)" default
}

src_install() {
	# ppd files are installed automagically. We have to create a directory
	# for them.
	dodir /usr/share/ppd

	# Also for the udev rules we have to create a directory to install them.
	dodir /lib/udev/rules.d

	# directories we have to create if we want foomaticdb support
	use foomaticdb && dodir /usr/share/foomatic/db/source

	emake DESTDIR="${ED%/}" \
		USBDIR="${ED%/}/etc/hotplug/usb" \
		UDEVDIR="${ED%/}/lib/udev/rules.d" \
		LIBUDEVDIR="${ED%/}/lib/udev/rules.d" \
		DOCDIR="${ED%}/usr/share/doc/${PF}" \
		-j1 install install-hotplug
}

src_test() {
	# see bug 419787
	: ;
}
