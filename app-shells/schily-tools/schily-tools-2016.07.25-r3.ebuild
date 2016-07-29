# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
inherit gnuconfig toolchain-funcs

MY_PV=${PV//./-}
MY_P="schily-${MY_PV}"
MY_P_TAR="${MY_P}.tar.bz2"
S=${WORKDIR}/${MY_P}

SRC_URI="mirror://sourceforge/schilytools/${MY_P}.tar.bz2"
DESCRIPTION="A modern enhanced and POSIX compliant Bourne Shell"
HOMEPAGE="https://sourceforge.net/projects/schilytools/"
KEYWORDS="~amd64 ~x86"
IUSE="acl caps static-libs system-libschily system-star xattr"

PATCHES=(
	"$FILESDIR"/fix_read.patch
	"$FILESDIR"/setuarg.patch
	"$FILESDIR"/testeq.patch
)

add_iuse_expand() {
	local i j
	j=${1}
	shift
	for i
	do	case ${i} in
		+*)
			IUSE=${IUSE}" +${j}_${i#?}";;
		*)
			IUSE=${IUSE}" ${j}_${i}";;
		esac
	done
}
add_iuse_expand renameschily \
	+calc +compare +count +jsh +man2html +p
add_iuse_expand schilytools \
	+bosh +calc +calltree +change +compare +copy +count +cpp +cstyle +cut \
	+hdump label +lndir +man2html manmake +match +mdigest mountcd osh \
	+p +paste +patch pxupgrade +sccs +sfind +smake \
	+termcap +translit +udiff +ved

COMMON="system-libschily? ( app-cdr/cdrtools )
!system-libschily? ( !app-cdr/cdrtools )
schilytools_match? (
	system-star? ( app-arch/star )
	!system-star? ( !app-arch/star )
)
schilytools_calc? (
	!renameschily_calc? ( !sci-mathematics/calc )
)
schilytools_compare? (
	!renameschily_compare? (
		!media-gfx/imagemagick !media-gfx/graphicsmagick[imagemagick]
	)
)
schilytools_count? (
	!renameschily_count? ( !sys-devel/llvm )
)
schilytools_bosh? (
	!renameschily_jsh? ( !app-shells/heirloom-sh )
)
schilytools_man2html? (
	!renameschily_man2html? ( !sys-apps/man )
)
schilytools_p? (
	!renameschily_p? ( !dev-util/wiggle )
)
acl? ( virtual/acl )
caps? ( sys-libs/libcap )
xattr? ( sys-apps/attr )"
DEPEND="${COMMON}"
RDEPEND="${COMMON}"
LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"

# Lot of this code is taken from app-cdr/cdrtools

cdrtools_os() {
	local os="linux"
	[[ ${CHOST} == *-darwin* ]] && os="mac-os10"
	[[ ${CHOST} == *-freebsd* ]] && os="freebsd"
	echo "${os}"
}

src_schily_prepare() {
	gnuconfig_update

	# Remove profiled make files.
	find -name '*_p.mk' -delete || die "delete *_p.mk"

	# Adjusting hardcoded paths.
	sed -i -e "s|opt/schily|usr|" \
		$(find ./ -type f -name \*.[0-9ch] -exec grep -l 'opt/schily' '{}' '+') \
		|| die "sed opt/schily"

	sed -i -e "s|\(^INSDIR=\t\tshare/doc/\)|\1${PF}/|" \
		$(find ./ -type f -exec grep -l '^INSDIR.\+doc' '{}' '+') \
		|| die "sed doc"

	# Respect libdir.
	sed -i -e "s|\(^INSDIR=\t\t\)lib|\1$(get_libdir)|" \
		$(find ./ -type f -exec grep -l '^INSDIR.\+lib\(/\(siconv\)\?\)\?$' '{}' '+') \
		|| die "sed multilib"

	# Respect libdir for defaults.smk
	sed -i -e "s|/lib/|/$(get_libdir)/|" \
		smake/Makefile \
		|| die "sed multilib for smake"

	# Enable verbose build.
	sed -i -e '/@echo.*==>.*;/s:@echo[^;]*;:&set -x;:' \
		RULES/*.rul RULES/rules.prg RULES/rules.inc \
		|| die "sed verbose rules"

	# Respect CC/CXX variables.
	cd "${S}"/RULES || die
	local tcCC=$(tc-getCC)
	local tcCXX=$(tc-getCXX)
	sed -i -e "/cc-config.sh/s|\$(C_ARCH:%64=%) \$(CCOM_DEF)|${tcCC} ${tcCC}|" \
		rules1.top || die "sed rules1.top"
	sed -i -e "/^CC_COM_DEF=/s|gcc|${tcCC}|" \
		-e "/^CC++_COM_DEF=/s|g++|${tcCXX}|" \
		-e "/COPTOPT=/s|-O||" \
		-e 's|$(GCCOPTOPT)||' \
		cc-gcc.rul || die "sed cc-gcc.rul"
	sed -i -e "s|^#\(CONFFLAGS +=\).*|\1\t-cc=${tcCC}|" \
		rules.cnf || die "sed rules.cnf"

	# Schily make setup.
	cd "${S}"/DEFAULTS || die
	local os=$(cdrtools_os)

	sed -i \
		-e "s|^\(DEFLINKMODE=\).*|\1\tdynamic|" \
		-e "s|^\(LINUX_INCL_PATH=\).*|\1|" \
		-e "s|^\(LDPATH=\).*|\1|" \
		-e "s|^\(RUNPATH=\).*|\1|" \
		-e "s|^\(INS_BASE=\).*|\1\t${ED}usr|" \
		-e "s|^\(INS_RBASE=\).*|\1\t${ED}|" \
		-e "s|^\(DEFINSGRP=\).*|\1\t0|" \
		-e '/^DEFUMASK/s,002,022,g' \
		Defaults.${os} || die "sed Schily make setup"
}

targets=""

targets() {
	local i
	for i
	do	case " ${targets} " in
		*" ${i} "*)
			continue;;
		esac
		mv -v UNUSED_TARGETS/??"${i}" TARGETS || die
		targets=${targets}${targets:+\ }${i}
	done
}

src_prepare() {
	default
	src_schily_prepare
	cd "${S}" || die
	sed -ie '1s!man1/sh\.1!man1/bosh.1!' -- "${S}/sh/"{jsh,pfsh}.1 || die
	sed -ie '/[+][=] -DPOSIX_BO[TS]H_PATH/iCPPOPTS += -DPOSIX_BOSH_PATH=\\"'"${EPREFIX}"'/bin/sh\\"' \
		-- "${S}/sh/"Makefile || die
	mkdir UNUSED_TARGETS || die
	mv TARGETS/[0-9][0-9]* UNUSED_TARGETS || die
	targets inc
	use system-libschily || targets include libschily libfind
	! use schilytools_bosh || targets sh libxtermcap libshedit libgetopt
	! use schilytools_calc || targets calc
	! use schilytools_calltree || targets calltree
	! use schilytools_change || targets change
# nonexistent:
#	! use schilytools_cmd || targets cmd
	! use schilytools_compare || targets compare
	! use schilytools_copy || targets copy
	! use schilytools_count || targets count
	! use schilytools_cpp || targets cpp
	! use schilytools_cstyle || targets cstyle
	! use schilytools_cut || targets cut
	! use schilytools_hdump || targets hdump
	! use schilytools_label || targets label
	! use schilytools_lndir || targets lndir
	! use schilytools_man2html || targets man2html
	! use schilytools_manmake || targets man
	! use schilytools_match || targets match
	! use schilytools_mdigest || targets mdigest
	! use schilytools_mountcd || targets mountcd
	! use schilytools_osh || targets osh libgetopt
	! use schilytools_p || targets p libxtermcap
	! use schilytools_paste || targets paste
	! use schilytools_patch || targets patch
	! use schilytools_pxupgrade || targets pxupgrade
	! use schilytools_sccs || targets sccs libgetopt
	! use schilytools_sfind || targets sfind
	! use schilytools_smake || targets smake
	! use schilytools_termcap || targets termcap libxtermcap
	! use schilytools_translit || targets translit
	! use schilytools_udiff || targets udiff
	! use schilytools_ved || targets ved libxtermcap
	eapply_user
}

ac_cv_sizeof() {
	cat <<-EOF >"${T}"/test.c
	#include <inttypes.h>
	#include <stddef.h>
	#include <stdint.h>
	#include <sys/types.h>
	int main () {
		static int test_array [1 - 2 * !((sizeof(TYPE)) == LEN)];
		test_array [0] = 0;
		return test_array [0];
	}
	EOF

	local i=1
	while [[ ${i} -lt 20 ]] ; do
		if ${CC} ${CPPFLAGS} ${CFLAGS} -c "${T}"/test.c -o /dev/null -DTYPE="$1" -DLEN=$i 2>/dev/null; then
			echo ${i}
			return 0
		fi
		: $(( i += 1 ))
	done
	return 1
}

src_configure() {
	use acl || export ac_cv_header_sys_acl_h="no"
	use caps || export ac_cv_lib_cap_cap_get_proc="no"
	use xattr || export ac_cv_header_attr_xattr_h="no"

	# skip obsolete configure script
	if tc-is-cross-compiler ; then
		# Cache known values for targets. #486680

		tc-export CC
		local var val t types=(
			char "short int" int "long int" "long long"
			"unsigned char" "unsigned short int" "unsigned int"
			"unsigned long int" "unsigned long long"
			float double "long double" size_t ssize_t ptrdiff_t
			mode_t uid_t gid_t pid_t dev_t time_t wchar_t
			"char *" "unsigned char *"
		)
		for t in "${types[@]}" ; do
			var="ac_cv_sizeof_${t// /_}"
			var=${var//[*]/p}
			val=$(ac_cv_sizeof "${t}") || die "could not compute ${t}"
			export "${var}=${val}"
			einfo "Computing sizeof(${t}) as ${val}"
		done
		# We don't have these types.
		export ac_cv_sizeof___int64=0
		export ac_cv_sizeof_unsigned___int64=0
		export ac_cv_sizeof_major_t=${ac_cv_sizeof_dev_t}
		export ac_cv_sizeof_minor_t=${ac_cv_sizeof_dev_t}
		export ac_cv_sizeof_wchar=${ac_cv_sizeof_wchar_t}

		export ac_cv_type_prototypes="yes"
		export ac_cv_func_mlock{,all}="yes"
		export ac_cv_func_{e,f,g}cvt=$(usex elibc_glibc)
		export ac_cv_func_dtoa_r="no"
		export ac_cv_func_sys_siglist{,_def}="no"
		export ac_cv_func_printf_{j,ll}="yes"
		export ac_cv_realloc_null="yes"
		export ac_cv_no_user_malloc="no"
		export ac_cv_var_timezone="yes"
		export ac_cv_var___progname{,_full}="yes"
		export ac_cv_fnmatch_igncase="yes"
		export ac_cv_file__dev_{fd_{0,1,2},null,std{err,in,out},tty,zero}="yes"
		export ac_cv_file__usr_src_linux_include="no"

		case $(cdrtools_os) in
		linux)
			export ac_cv_func_bsd_{g,s}etpgrp="no"
			export ac_cv_hard_symlinks="yes"
			export ac_cv_link_nofollow="yes"
			export ac_cv_access_e_ok="no"

			export ac_cv_dev_minor_noncontig="yes"
			case ${ac_cv_sizeof_long_int} in
			4) export ac_cv_dev_minor_bits="32";;
			8) export ac_cv_dev_minor_bits="44";;
			esac

			cat <<-EOF >"${T}"/test.c
			struct {
				char start[6];
				unsigned char x1:4;
				unsigned char x2:4;
				char end[5];
			} a = {
				.start = {'S', 't', 'A', 'r', 'T', '_'},
				.x1 = 5,
				.x2 = 4,
				.end = {'_', 'e', 'N', 'd', 'X'},
			};
			EOF
			${CC} ${CPPFLAGS} ${CFLAGS} -c "${T}"/test.c -o "${T}"/test.o
			if grep -q 'StArT_E_eNdX' "${T}"/test.o ; then
				export ac_cv_c_bitfields_htol="no"
			elif grep -q 'StArT_T_eNdX' "${T}"/test.o ; then
				export ac_cv_c_bitfields_htol="yes"
			fi
			;;
		esac
	fi
	cd psmake || die
}

src_compile() {
	emake -j1 CPPOPTX="${CPPFLAGS}" COPTX="${CFLAGS}" C++OPTX="${CXXFLAGS}" \
		LDOPTX="${LDFLAGS}" GMAKE_NOWARN="true"
}

mustnothave() {
	local i
	for i
	do	test -r "${ED}${i}" && die "${ED}${i} must not exist"
	done
}

mustremove() {
	local i
	for i
	do	test -r "${ED}${i}" && rm -v -- "${ED}${i}" || \
			die "cannot remove ${ED}${i}"
	done
}

src_install() {
	emake -j1 CPPOPTX="${CPPFLAGS}" COPTX="${CFLAGS}" C++OPTX="${CXXFLAGS}" \
		LDOPTX="${LDFLAGS}" GMAKE_NOWARN="true" install
	if ! use static-libs
	then	find "${ED}" -name '*.a' -delete || die
		! test -d "${ED}"usr/include || rm -rfv -- "${ED}"usr/include || die
	fi
	if use schilytools_sccs
	then	mv -v "${ED}"usr/share/man/man1/{,sccs-}diff.1 || die
	else	! test -d "${ED}"usr/ccs || rm -rfv -- "${ED}"usr/ccs || die
		mustnothave usr/share/man/man1/diff.1
	fi
	if use schilytools_hdump
	then	mustremove usr/bin/od usr/share/man/man1/od.1
	else	mustnothave usr/bin/od usr/share/man/man1/od.1
	fi
	if use schilytools_patch
	then	mustremove usr/share/man/man1/patch.1
	else	mustnothave usr/share/man/man1/patch.1
	fi
	if use schilytools_bosh
	then	dodir bin || die
		rm -v "${ED}"usr/bin/{bo,j,pf}sh \
			"${ED}"usr/share/man/man1/bosh.1 || die
		mv -v -- "${ED}"{usr/bin/sh,bin/bosh} || die
		ln -s -- bosh "${ED}"/bin/jsh || die
		ln -s -- bosh "${ED}"/bin/pfsh || die
		mv -v -- "${ED}"usr/share/man/man1/{,bo}sh.1 || die
		if use renameschily_jsh
		then	mv -v -- "${ED}"bin/{,s}jsh || die
			mv -v -- "${ED}"usr/share/man/man1/{,s}jsh.1 || die
		fi
	fi
	if use schilytools_match && use system-star
	then	rm -v -- "${ED}"usr/share/man/man1/match.1 || die
	fi
	if use schilytools_calc && use renameschily_calc
	then	mv -v -- "${ED}"usr/bin/{,s}calc || die
		mv -v -- "${ED}"usr/share/man/man1/{,s}calc.1 || die
	fi
	if use schilytools_compare && use renameschily_compare
	then	mv -v -- "${ED}"usr/bin/{,s}compare || die
		mv -v -- "${ED}"usr/share/man/man1/{,s}compare.1 || die
	fi
	if use schilytools_count && use renameschily_count
	then	mv -v -- "${ED}"usr/bin/{,s}count || die
		mv -v -- "${ED}"usr/share/man/man1/{,s}count.1 || die
	fi
	if use schilytools_man2html && use renameschily_man2html
	then	mv -v -- "${ED}"usr/bin/{,s}man2html || die
		mv -v -- "${ED}"usr/share/man/man1/{,s}man2html.1 || die
	fi
	if use schilytools_p && use renameschily_p
	then	mv -v -- "${ED}"usr/bin/{,s}p || die
		mv -v -- "${ED}"usr/share/man/man1/{,s}p.1 || die
	fi
	if use schilytools_ved
	then	docompress -x /usr/share/man/help
	fi
}
