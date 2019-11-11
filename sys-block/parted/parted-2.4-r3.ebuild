# Copyright 1999-2018 Martin V\"ath and others
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="Create, destroy, resize, check, copy partitions and file systems"
HOMEPAGE="https://www.gnu.org/software/parted"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="+debug device-mapper nls readline selinux standalone static-libs"
RESTRICT="test"

# specific version for gettext needed
# to fix bug 85999
RDEPEND="
	>=sys-fs/e2fsprogs-1.27
	>=sys-libs/ncurses-5.2:0=
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	readline? ( >=sys-libs/readline-5.2:0= )
	selinux? ( sys-libs/libselinux )
	standalone? ( !sys-block/parted:0 )
	!standalone? ( sys-block/parted:0 )
"
DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"
BDEPEND="nls? ( >=sys-devel/gettext-0.12.1-r2 )"
PATCHES=(
	"${FILESDIR}"/${P}-no-gets.patch
	"${FILESDIR}"/${P}-readline.patch
	"${FILESDIR}"/${P}-glibc-2.28.patch
	"${FILESDIR}"/${PN}-3.2-sysmacros.patch
)
DOCS=( AUTHORS BUGS ChangeLog NEWS README THANKS TODO doc/{API,FAT,USER.jp} )

src_prepare() {
	if ! use standalone; then
		sed -i -e "s/GNU parted/GNU parted2/" "${S}"/configure.ac
		sed -i -e "s/partedinclude_HEADERS/partedinclude_NOINST/" \
			"${S}"/include/parted/Makefile.am || die
		sed -i -e "/SUBDIRS.*=/{s/[[:space:]]*partprobe//}" \
			-e "s/pc_DATA/pc_NOINST/" \
			"${S}"/Makefile.am || die
		sed -i -e "/partprobe.8/d" -e "s/parted[.]8.*/parted2.8/" \
			"${S}"/doc/C/Makefile.am || die
		sed -i -e "s/parted/parted2/g" \
			-e "s/PARTED/PARTED2/g" -e "s/Parted/Parted2/g" \
			"${S}"/doc/parted*.* \
			"${S}"/doc/Makefile.am || die
		mv "${S}"/doc/C/parted{,2}.8 || die
		mv "${S}"/doc/parted{,2}.texi || die
		mv "${S}"/doc/parted{,2}-pt_BR.texi || die
	fi
	default
	use standalone || eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable device-mapper) \
		$(use_enable nls) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		$(use_with readline) \
		--disable-Werror \
		--disable-rpath \
		--disable-silent-rules
}

src_install() {
	default
	if ! use standalone; then
		mv "${ED}"/usr/sbin/parted{,2} || die
		rm "${ED}"/usr/$(get_libdir)/libparted.so || die
	fi
	find "${D}" -name '*.la' -delete || die
}
