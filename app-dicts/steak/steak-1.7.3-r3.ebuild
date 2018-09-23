# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
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
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

BDEPEND="app-text/recode"
! ${use_rpm} || BDEPEND=${BDEPEND}" app-arch/rpm2targz"
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
	default
	recode latin1..utf8 "${S}"/Datensatz/ger-eng.txt || die
}

src_install() {
	insinto /usr/share/Steak/Datensatz
	doins Datensatz/ger-eng.txt

	insinto /usr/share/Steak
	doins mini_steak_icon.xpm pinguin_steak_icon.xpm .Steakconfig

	dobin woerterbuch printbuffer iso2txt spacefilter poll
	dosym woerterbuch /usr/bin/steak

	dodoc copyrights.txt help.txt version.txt README README.eng
}
