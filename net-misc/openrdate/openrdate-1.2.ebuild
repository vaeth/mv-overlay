# Copyright 1999-2022 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools

DESCRIPTION="use TCP or UDP to retrieve the current time of another machine"
HOMEPAGE="https://sourceforge.net/projects/openrdate/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.1.3-rename.patch
	"${FILESDIR}"/sysctl.patch
)

src_prepare() {
	default
	eautomake
	mv docs/{,open}rdate.8
}

src_configure() {
	export CFLAGS="${CFLAGS-} -D__NO_SYSCTL__"
	default
}

src_install(){
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	newinitd "${FILESDIR}"/openrdate-initd openrdate
	newconfd "${FILESDIR}"/openrdate-confd openrdate
}
