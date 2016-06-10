# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit flag-o-matic gnuconfig toolchain-funcs

MY_PV=${PV//./-}
MY_P="schily-${MY_PV}"
MY_P_TAR="${MY_P}.tar.bz2"
S=${WORKDIR}/${MY_P}

SRC_URI="mirror://sourceforge/schilytools/${MY_P}.tar.bz2"
DESCRIPTION="A modern enhanced and POSIX compliant Bourne Shell"
HOMEPAGE="http://schilytools.sourceforge.net/bosh.htm"
KEYWORDS="~amd64 ~x86"
IUSE="acl caps system-libschily system-star xattr"

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
	+bosh +calc +calltree +change +compare +copy +count +cstyle +cut \
	label +lndir +man2html +match +mdigest mountcd +osh \
	+p +paste +patch pxupgrade +sfind +smake termcap +translit +udiff +ved

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
	find -name '*_p.mk' -delete

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
	cd "${S}"/RULES
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
	cd "${S}"/DEFAULTS
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

src_prepare() {
	local s_xtermcap=false
	src_schily_prepare
	filter-flags -fPIE -pie -flto* -fwhole-program -fno-common
	cd "${S}" || die
	sed -ie '1s!man1/sh\.1!man1/bosh.1!' -- "${S}/sh/"{jsh,pfsh}.1 || die
	mkdir UNUSED_TARGETS || die
	mv TARGETS/[0-9][0-9]* UNUSED_TARGETS || die
	use system-libschily || mv -v \
		UNUSED_TARGETS/??inc \
		UNUSED_TARGETS/??include \
		UNUSED_TARGETS/??libschily \
		UNUSED_TARGETS/??libfind \
		TARGETS || die
	mv -v \
		UNUSED_TARGETS/??libgetopt \
		UNUSED_TARGETS/??libshedit \
		TARGETS || die
	if use schilytools_bosh
	then	mv -v UNUSED_TARGETS/??sh TARGETS || die
		s_xtermcap=:
	fi
	! use schilytools_calc || mv -v UNUSED_TARGETS/??calc TARGETS || die
	! use schilytools_calltree || mv -v UNUSED_TARGETS/??calltree TARGETS || die
	! use schilytools_change || mv -v UNUSED_TARGETS/??change TARGETS || die
# nonexistent:
#	! use schilytools_cmd || mv -v UNUSED_TARGETS/??cmd TARGETS || die
	! use schilytools_compare || mv -v UNUSED_TARGETS/??compare TARGETS || die
	! use schilytools_copy || mv -v UNUSED_TARGETS/??copy TARGETS || die
	! use schilytools_count || mv -v UNUSED_TARGETS/??count TARGETS || die
	! use schilytools_cstyle || mv -v UNUSED_TARGETS/??cstyle TARGETS || die
	! use schilytools_cut || mv -v UNUSED_TARGETS/??cut TARGETS || die
# broken:
#	! use schilytools_hdump || mv -v UNUSED_TARGETS/??hdump TARGETS || die
	! use schilytools_label || mv -v UNUSED_TARGETS/??label TARGETS || die
	! use schilytools_lndir || mv -v UNUSED_TARGETS/??lndir TARGETS || die
	! use schilytools_man2html || mv -v UNUSED_TARGETS/??man2html TARGETS || die
	! use schilytools_match || mv -v UNUSED_TARGETS/??match TARGETS || die
	! use schilytools_mdigest || mv -v UNUSED_TARGETS/??mdigest TARGETS || die
	! use schilytools_mountcd || mv -v UNUSED_TARGETS/??mountcd TARGETS || die
	! use schilytools_osh || mv -v UNUSED_TARGETS/??osh TARGETS || die
	if use schilytools_p
	then	mv -v UNUSED_TARGETS/??p TARGETS || die
		s_xtermcap=:
	fi
	! use schilytools_paste || mv -v UNUSED_TARGETS/??paste TARGETS || die
	! use schilytools_patch || mv -v UNUSED_TARGETS/??patch TARGETS || die
	! use schilytools_pxupgrade || mv -v UNUSED_TARGETS/??pxupgrade TARGETS || die
# broken:
#	! use schilytools_sccs || mv -v UNUSED_TARGETS/??sccs TARGETS || die
	! use schilytools_sfind || mv -v UNUSED_TARGETS/??sfind TARGETS || die
	! use schilytools_smake || mv -v UNUSED_TARGETS/??smake TARGETS || die
	if use schilytools_termcap
	then	mv -v UNUSED_TARGETS/??termcap TARGETS || die
		s_xtermcap=:
	fi
	! use schilytools_translit || mv -v UNUSED_TARGETS/??translit TARGETS || die
	! use schilytools_udiff || mv -v UNUSED_TARGETS/??udiff TARGETS || die
	if use schilytools_ved
	then	mv -v UNUSED_TARGETS/??ved TARGETS || die
		s_xtermcap=:
	fi
	! ${s_xtermcap} || mv -v UNUSED_TARGETS/??libxtermcap TARGETS || die
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

src_install() {
	emake -j1 CPPOPTX="${CPPFLAGS}" COPTX="${CFLAGS}" C++OPTX="${CXXFLAGS}" \
		LDOPTX="${LDFLAGS}" GMAKE_NOWARN="true" install
	find "${ED}" -name '*.a' -delete
	rm -rfv -- "${ED}"usr/{include,ccs}
	if use schilytools_bosh
	then	dodir bin || die
		rm -v "${ED}"usr/bin/{bo,j,pf}sh \
			"${ED}"usr/share/man/man1/bosh.1* || die
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
	then	rm -v -- "${ED}"usr/share/man/man1/match.1* || die
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
}
