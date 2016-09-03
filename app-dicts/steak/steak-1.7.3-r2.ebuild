# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

DESCRIPTION="EN => DE Dictionary"
HOMEPAGE="http://www.tm.informatik.uni-frankfurt.de/~razi/steak/steak.html"
HOMEPAGE="http://www.tm.informatik.uni-frankfurt.de/~razi/steak"
#SRC_URI="http://www.tm.informatik.uni-frankfurt.de/~razi/steak/program/Steak.${PV}.tar.gz"
SRC_URI="http://www-stud.rbi.informatik.uni-frankfurt.de/~razi/steak/program/Steak.${PV}.tar.bz2"
use_rpm=false
if $use_rpm
then	SRC_URI="ftp://84.41.185.108/suse/9.1/suse/src/${P}-251.src.rpm"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

DEPEND="app-text/recode"
! ${use_rpm} || DEPEND=${DEPEND}" app-arch/rpm2targz"
RDEPEND=""

S=${WORKDIR}/Steak

PATCHES=("${FILESDIR}/${P}.patch")

! ${use_rpm} || src_unpack() {
	cd "${WORKDIR}"
	rpm2targz "${DISTDIR}/${A}"
	tar -xzf "${P}-251.src.tar.gz"
	tar -xjpf "Steak.${PV}.tar.bz2"
}

src_prepare() {
	eapply_user
	recode latin1..utf8 "${S}"/Datensatz/ger-eng.txt || die
}

src_install() {
	insinto /usr/share/Steak/Datensatz
	doins Datensatz/ger-eng.txt

	insinto /usr/share/Steak
	doins mini_steak_icon.xpm pinguin_steak_icon.xpm .Steakconfig

	dobin woerterbuch printbuffer iso2txt spacefilter poll
	dosym /usr/bin/woerterbuch /usr/bin/steak

	dodoc copyrights.txt help.txt version.txt README README.eng
}
