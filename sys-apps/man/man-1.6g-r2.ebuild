# Copyright 1999-2020 Martin V\"ath and Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils prefix toolchain-funcs user

DESCRIPTION="Standard commands to read man pages"
HOMEPAGE="http://primates.ximian.com/~flucifredi/man/"
SRC_URI="http://primates.ximian.com/~flucifredi/man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd"
IUSE="cache +lzma nls selinux"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=">=sys-apps/groff-1.19.2-r1
	!sys-apps/man-db
	!<app-arch/lzma-4.63
	lzma? ( app-arch/xz-utils )
	selinux? ( sec-policy/selinux-makewhatis )"

pkg_setup() {
	enewgroup man 15
	enewuser man 13 -1 /usr/share/man man
}

src_prepare() {
	eapply -p0 "${FILESDIR}"/man-1.6f-man2html-compression-2.patch
	eapply -p0 "${FILESDIR}"/man-1.6-cross-compile.patch
	eapply "${FILESDIR}"/man-1.6f-unicode.patch #146315
	eapply "${FILESDIR}"/man-1.6c-cut-duplicate-manpaths.patch
	eapply "${FILESDIR}"/man-1.5m2-apropos.patch
	eapply "${FILESDIR}"/man-1.6g-fbsd.patch #138123
	eapply -p0 "${FILESDIR}"/man-1.6e-headers.patch
	eapply "${FILESDIR}"/man-1.6f-so-search-2.patch
	eapply -p0 "${FILESDIR}"/man-1.6g-compress.patch #205147
	eapply "${FILESDIR}"/man-1.6f-parallel-build.patch #207148 #258916
	eapply "${FILESDIR}"/man-1.6g-xz.patch #302380
	eapply "${FILESDIR}"/man-1.6f-makewhatis-compression-cleanup.patch #331979
	eapply "${FILESDIR}"/man-1.6g-echo-escape.patch #523874
	eapply "${FILESDIR}"/man-1.6g-gawk-5.patch #683494
	# make sure `less` handles escape sequences #287183
	sed -i -e '/^DEFAULTLESSOPT=/s:"$:R":' configure
	default
}

echoit() { echo "$@" ; "$@" ; }
src_configure() {
	local mylang=
	strip-linguas $(eval $(grep ^LANGUAGES= configure) ; echo ${LANGUAGES//,/ })

	unset NLSPATH #175258

	tc-export CC BUILD_CC

	if use nls ; then
		if [[ -z ${LINGUAS} ]] ; then
			mylang="all"
		else
			mylang="${LINGUAS// /,}"
		fi
	else
		mylang="none"
	fi
	export COMPRESS
	if use lzma ; then
		COMPRESS="${EPREFIX}"/usr/bin/xz
	else
		COMPRESS="${EPREFIX}"/bin/bzip2
	fi

	if [[ -n ${EPREFIX} ]]; then
		hprefixify configure || die
		sed -i \
			-e "s/man_user=root/man_user=$(id -u)/"  \
			-e "s/man_group=man/man_group=$(id -g)/" \
			configure || die "Failed to disable suid/sgid options for man"
		sed -i -e 's:/usr/bin:@bindir@:' man2html/Makefile.in || die
	fi

	echoit \
	./configure \
		-bindir="${EPREFIX}"/usr/bin \
		-confdir="${EPREFIX}"/etc \
		+sgid +fhs \
		+lang ${mylang} \
		|| die "configure failed"
}

src_install() {
	unset NLSPATH #175258

	emake PREFIX="${ED}" install || die "make install failed"
	dosym man /usr/bin/manpath

	dodoc LSM README* TODO

	# makewhatis only adds man-pages from the last 24hrs
	exeinto /etc/cron.daily
	newexe "${FILESDIR}"/makewhatis.cron makewhatis

	keepdir /var/cache/man
	[[ -z ${EPREFIX} ]] && diropts -m0775 -g man
	local mansects=$(grep ^MANSECT "${ED}"/etc/man.conf | cut -f2-)
	for x in ${mansects//:/ } ; do
		keepdir /var/cache/man/cat${x}
	done
}

pkg_postinst() {
	local files f i
	einfo "Forcing sane permissions onto ${ROOT}/var/cache/man (Bug #40322)"
	if use cache ; then
		chown -R root:man "${EROOT}"/var/cache/man
		chmod -R g+w "${EROOT}"/var/cache/man
		[[ -e ${EROOT}/var/cache/man/whatis ]] \
			&& chown root:0 "${EROOT}"/var/cache/man/whatis
	elif test -d "${EROOT}"/var/cache/man ; then
		rm -rfv -- "${EROOT}"/var/cache/man
	fi

	echo

	for f in "${EROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} ; do
		case ${f} in
		*/etc/cron.daily/makewhatis)
			continue;;
		esac
		test -r "${f}" || continue
		case $(md5sum -- "${f}") in
		"8b2016cc778ed4e2570b912c0f420266 "*)
			rm -f -- "${f}";;
		esac
	done
	files=
	i=false
	for f in "${EROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} ; do
		test -r "${f}" || continue
		if [ -z "${files}" ] ; then
			files=${f}
		else
			files="${files} ${f}"
			i=:
		fi
	done
	if ${i} ; then
		ewarn "You have multiple makewhatis cron files installed."
		ewarn "You might want to delete all but one of these:"
		ewarn "${files}"
	fi
}
