# Copyright 1999-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Wolfgang Friebel's preprocessor for sys-apps/less. Disable by appending colon"
HOMEPAGE="https://github.com/wofr06/lesspipe"
SRC_URI="https://www-zeuthen.desy.de/~friebel/unix/less/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

case ${PV} in
9999*)
	EGIT_REPO_URI="https://github.com/wofr06/${PN}.git"
	#EGIT_BRANCH="master"
	EGIT_BRANCH="lesspipe"
	inherit git-r3
	SRC_URI=""
	KEYWORDS="";;
*alpha*)
	RESTRICT="mirror"
	EGIT_COMMIT="87ac1d025ba3417d7703b3ca57d52da055b5b21e"
	SRC_URI="https://github.com/vaeth/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
esac
inherit required-use-warn
pkg_pretend() {
	required-use-warn
}

IUSE="antiword cabextract catdoc +cpio +djvu dpkg +dvi2tty +elinks fastjar +ghostscript gpg +groff hdf5 +html2text id3v2 image isoinfo libplist +links +lynx lzip mp3info mp3info2 netcdf ooffice p7zip pdf pstotext rar rpm +rpm2targz unrar unrtf +unzip +w3m xlhtml"

htmlmode="( || ( html2text links lynx elinks w3m ) )"
REQUIRED_USE="!rpm2targz? ( rpm? ( cpio ) )
	ooffice? ${htmlmode}
	xlhtml? ${htmlmode}"
REQUIRED_USE_WARN="
	alpha? ( !catdoc !fastjar !id3v2 !libplist !mp3info !mp3info2 !netcdf
		!ooffice !pstotext !rar )
	amd64-fbsd? ( !antiword !catdoc !dpkg !elinks !fastjar !hdf5 !html2text
		!id3v2 !lzip !mp3info !mp3info2 !netcdf !ooffice !p7zip !pstotext
		!rar !rpm !unrtf !w3m !xlhtml )
	arm? ( !antiword !catdoc !fastjar !html2text !id3v2 !mp3info
		!ooffice !pstotext !rar !xlhtml )
	arm64? ( !antiword !catdoc !dpkg !elinks !fastjar !html2text !id3v2
		!mp3info !mp3info2 !netcdf !ooffice !pstotext !rar !unrtf !xlhtml )
	hppa? ( !catdoc !fastjar !hdf5 !libplist !mp3info2 !netcdf
		!ooffice !rar !w3m !xlhtml )
	ia64? ( !antiword !catdoc !fastjar !id3v2 !libplist !mp3info !mp3info2
		!netcdf !ooffice !pstotext !rar !xlhtml )
	ppc64? ( !catdoc !fastjar !ooffice !xlhtml )
	sparc? ( !catdoc !fastjar !id3v2 !libplist !mp3info2 !netcdf
		!ooffice !pstotext )"

BOTH_DEPEND="sys-apps/file
	app-arch/xz-utils
	app-arch/bzip2
	dev-lang/perl
	unzip? ( app-arch/unzip )
	fastjar? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !hppa? ( !ia64?
		( !ppc64? ( !sparc? ( app-arch/fastjar ) ) ) ) ) ) ) ) )
	unrar? ( app-arch/unrar )
	!unrar? (
		rar? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !hppa? ( !ia64?
			( app-text/o3read ) ) ) ) ) ) )
	)
	lzip? ( !amd64-fbsd? ( app-arch/lzip ) )
	p7zip? ( !amd64-fbsd? ( app-arch/p7zip ) )
	cpio? ( app-arch/cpio )
	cabextract? ( app-arch/cabextract )
	html2text? ( !amd64-fbsd? ( !arm? ( !arm64? ( app-text/html2text ) ) ) )
	!html2text? (
		links? ( www-client/links )
		!links? (
			lynx? ( www-client/lynx )
			!lynx? (
				elinks? ( !amd64-fbsd? ( !arm64? ( www-client/elinks ) ) )
				!elinks? (
					w3m? ( !amd64-fbsd? ( !hppa? ( www-client/w3m ) ) )
				)
			)
		)
	)
	groff? ( sys-apps/groff )
	rpm2targz? ( app-arch/rpm2targz )
	!rpm2targz? (
		rpm? ( !amd64-fbsd? ( app-arch/rpm ) )
	)
	antiword? ( !amd64-fbsd? ( !arm? ( !arm64? ( !ia64?
		( app-text/antiword ) ) ) ) )
	!antiword? (
		catdoc? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !hppa? ( !ia64?
			( !ppc64? ( !sparc? ( app-text/catdoc ) ) ) ) ) ) ) ) )
	)
	xlhtml? ( !amd64-fbsd? ( !arm? ( !arm64? ( !hppa? ( !ia64? ( !ppc64?
		( app-text/xlhtml ) ) ) ) ) ) )
	unrtf? ( !amd64-fbsd? ( !arm64? ( app-text/unrtf ) ) )
	djvu? ( app-text/djvu )
	dvi2tty? ( dev-tex/dvi2tty )
	pstotext? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !ia64? ( !sparc?
		( app-text/pstotext ) ) ) ) ) ) )
	!pstotext? (
		ghostscript? ( app-text/ghostscript-gpl )
	)
	gpg? ( app-crypt/gnupg )
	pdf? ( app-text/poppler )
	id3v2? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !ia64? ( !sparc?
		( media-sound/id3v2 ) ) ) ) ) ) )
	!id3v2? (
		mp3info2? ( !alpha? ( !amd64-fbsd? ( !arm64? ( !hppa? ( !ia64?
			( !sparc? ( dev-perl/MP3-Tag ) ) ) ) ) ) )
		!mp3info2? (
			mp3info? ( !alpha? ( !amd64-fbsd? ( !arm? ( !arm64? ( !ia64?
				( media-sound/mp3info ) ) ) ) ) )
		)
	)
	image? ( virtual/imagemagick-tools )
	isoinfo? ( || ( virtual/cdrtools app-cdr/dvd+rw-tools ) )
	libplist? ( !alpha? ( !hppa? ( !ia64? ( !sparc?
		( app-pda/libplist ) ) ) ) )
	dpkg? ( !amd64-fbsd? ( !arm64? ( app-arch/dpkg ) ) )
	hdf5? ( !amd64-fbsd? ( !hppa? ( sci-libs/hdf5 ) ) )
	netcdf? ( !alpha? ( !amd64-fbsd? ( !arm64?  ( !hppa? ( !ia64? ( !sparc?
		( sci-libs/netcdf ) ) ) ) ) ) )"
DEPEND="${BOTH_DEPEND}"
RDEPEND="${BOTH_DEPEND}
	sys-apps/less
	!<sys-apps/less-483-r1"

ModifyStart() {
	sedline=
}

Modify() {
	if [ -z "${sedline:++}" ]
	then	sedline='/^__END__$/,${'
	else	sedline=${sedline}';'
	fi
	sedline=${sedline}'s/^\('${1}'[[:space:]][[:space:]]*\)[nNyY]/\1'${2:-Y}'/'
}

ModifyEnd() {
	sedline=${sedline}'}'
	sed -i -e "${sedline}" "${S}/configure" || die
}

ModifyY() {
	local i
	for i
	do	Modify "${i}"
	done
}

ModifyN() {
	local i
	for i
	do	Modify "${i}" N
	done
}

ModifyX() {
	if [ ${?} -eq 0 ]
	then	ModifyY "${@}"
	else	ModifyN "${@}"
	fi
}

ModifyU() {
	local i
	for i
	do	use "${i}"; ModifyX "${i}"
	done
}

Modify1() {
	local i search
	search=:
	for i
	do	${search} && use "${i}" && search=false; ModifyX "${i}"
	done
}

src_prepare() {
	printf 'h5dump\t\tN\nncdump\t\tN\n' >>"${S}/configure"
	ModifyStart
	ModifyY 'HILITE'
	ModifyY 'LESS_ADVANCED_PREPROCESSOR'
	ModifyY 'nm'
	ModifyY 'iconv'
	ModifyY 'bzip2'
	ModifyY 'xz' 'lzma'
	ModifyY 'perldoc'
	ModifyU 'unzip' 'fastjar'
	Modify1 'unrar' 'rar'
	ModifyU 'lzip'
	use p7zip; ModifyX '7za'
	ModifyU 'cpio' 'cabextract' 'groff'
	Modify1 'html2text' 'links' 'lynx' 'elinks' 'w3m'
	use rpm2targz; ModifyX 'rpmunpack'
	! use rpm2targz && use rpm; ModifyX 'rpm' 'rpm2cpio'
	Modify1 'antiword' 'catdoc'
	use xlhtml; ModifyX 'ppthtml' 'xlhtml'
	ModifyU 'unrtf'
	use ooffice; ModifyX 'o3tohtml'
	use djvu; ModifyX 'djvutxt'
	ModifyU 'dvi2tty'
	ModifyU 'pstotext'
	! use pstotext && use ghostscript; ModifyX 'ps2ascii'
	ModifyU 'gpg'
	use pdf; ModifyX 'pdftohtml' 'pdftotext'
	Modify1 'id3v2' 'mp3info2' 'mp3info'
	use image; ModifyX 'identify'
	ModifyU 'isoinfo'
	ModifyN 'dpkg'
	ModifyN 'lsbom'
	use libplist; ModifyX 'plutil'
	use hdf5; ModifyX 'h5dump'
	use netcdf; ModifyX 'ncdump'
	ModifyEnd
	printf '%s\n' 'LESS_ADVANCED_PREPROCESSOR=1' >70lesspipe || die
	default
}

src_configure() {
	./configure --fixed --prefix=/usr || die
}

src_compile() {
	:
}

src_install() {
	doenvd 70lesspipe
	dodir /usr/share/man/man1
	default
}
