# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic prefix readme.gentoo-r1

MY_PV=${PV/_p/-dev-}
S=${WORKDIR}/${PN}-${MY_PV}

zsh_ftp="http://www.zsh.org/pub"

ZSH_URI="${zsh_ftp}/${PN}-${MY_PV}.tar.xz"
ZSH_DOC_URI="${zsh_ftp}/${PN}-${PV%_*}-doc.tar.xz"

DESCRIPTION="UNIX Shell similar to the Korn shell"
HOMEPAGE="http://www.zsh.org/"
case ${PV} in
9999*)
	SRC_URI=""
	EGIT_REPO_URI="git://git.code.sf.net/p/zsh/code"
	inherit git-r3
	WANT_LIBTOOL="none"
	inherit autotools
	KEYWORDS=""
# Creating help files needs util-linux for colcrt.
# Please let me know if you have an arch where "colcrt" (or at least "col")
# is provided by a different package.
	DEPEND="app-text/yodl
		dev-lang/perl
		sys-apps/man
		sys-apps/util-linux
		doc? (
			sys-apps/texinfo
			app-text/texi2html
			virtual/latex-base
		)"
	PROPERTIES="live"
	LIVE=:;;
*)
	SRC_URI="${ZSH_URI}
		doc? ( ${ZSH_DOC_URI} )"
	#KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~m68k ~mips ppc ~ppc64 ~s390 ~sh sparc x86 ~x64-cygwin ~x64-cygwin ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	DEPEND=""
	LIVE=false;;
esac

LICENSE="ZSH gdbm? ( GPL-2 )"
SLOT="0"
IUSE="caps compile"
COMPLETIONS="AIX BSD Cygwin Darwin Debian +Linux Mandriva openSUSE Redhat Solaris +Unix +X"
for curr in ${COMPLETIONS}
do	case ${curr} in
	[+-]*)
		IUSE+=" ${curr%%[!+-]*}completion_${curr#?}"
		continue;;
	esac
	IUSE+=" completion_${curr}"
done
IUSE+=" debug doc examples gdbm maildir pcre static unicode"

RDEPEND="
	>=sys-libs/ncurses-5.1:0=
	static? ( >=sys-libs/ncurses-5.7-r4:0=[static-libs] )
	caps? ( sys-libs/libcap )
	pcre? (
		>=dev-libs/libpcre-3.9
		static? ( >=dev-libs/libpcre-3.9[static-libs] )
	)
	gdbm? ( sys-libs/gdbm )
"
DEPEND+="
	sys-apps/groff
	${RDEPEND}"
PDEPEND="
	examples? ( app-doc/zsh-lovers )
"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="
If you want to enable Portage completions and Gentoo prompt,
emerge app-shells/gentoo-zsh-completion and add
	autoload -U compinit promptinit
	compinit
	promptinit; prompt gentoo
to your ~/.zshrc

Also, if you want to enable cache for the completions, add
	zstyle ':completion::complete:*' use-cache 1
to your ~/.zshrc

If you want to use run-help add to your ~/.zshrc
	unalias run-help
	autoload -Uz run-help

Note that a system zprofile startup file is installed. This will override
PATH and possibly other variables that a user may set in ~/.zshenv.
Custom PATH settings and similar overridden variables can be moved
to ~/.zprofile or other user startup files that are sourced after the
system zprofile.

If PATH must be set in ~/.zshenv to affect things like non-login ssh shells,
one method is to use a separate path-setting file that is conditionally sourced
in ~/.zshenv and also sourced from ~/.zprofile. For more information, see the
zshenv example in "${EROOT}"/usr/share/doc/${PF}/StartupFiles/.

See https://wiki.gentoo.org/wiki/Zsh/HOWTO for more introduction documentation.
"

fix_soelim() {
	# fix zshall problem with soelim
	ln -s Doc man1 || die
	mv Doc/zshall.1 Doc/zshall.1.soelim || die
	soelim Doc/zshall.1.soelim > Doc/zshall.1 || die
}

src_prepare() {
	${LIVE} || fix_soelim

	${LIVE} || eapply "${FILESDIR}"/${PN}-init.d-gentoo-r1.diff

	cp "${FILESDIR}"/zprofile-1 "${T}"/zprofile || die
	eprefixify "${T}"/zprofile || die
	if use prefix ; then
		sed -i -e 's|@ZSH_PREFIX@||' -e '/@ZSH_NOPREFIX@/d' "${T}"/zprofile || die
	else
		sed -i -e 's|@ZSH_NOPREFIX@||' -e '/@ZSH_PREFIX@/d' -e 's|""||' "${T}"/zprofile || die
	fi
	set --
	file='Src/Zle/complete.mdd'
	for i in ${COMPLETIONS}
	do	case ${i} in
		[+-]*)
			i=${i#?};;
		esac
		grep -q "Completion\/${i}" -- "${S}/${file}" \
			|| die "${file} does not contain Completion/${i}"
		use completion_${i} || set -- "${@}" -e "s/Completion\/${i}[^ ']*//"
	done
	[ ${#} -eq 0 ] || sed -i "${@}" -- "${S}/${file}" \
		|| die "patching ${file} failed"
	eapply_user
	! ${LIVE} || eautoreconf
	PVPATH=$(. "${S}"/Config/version.mk && printf '%s' "${VERSION}") && \
		[ -n "${PVPATH}" ] || PVPATH=${PV}
}

src_configure() {
	local myconf
	myconf=()

	if use static ; then
		myconf+=( --disable-dynamic )
		append-ldflags -static
	fi
	if use debug ; then
		myconf+=(
			--enable-zsh-debug
			--enable-zsh-mem-debug
			--enable-zsh-mem-warning
			--enable-zsh-secure-free
			--enable-zsh-hash-debug
		)
	fi

	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=( --enable-libs=-liconv )
		append-ldflags -Wl,-x
	fi

	econf \
		--bindir="${EPREFIX}"/bin \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-etcdir="${EPREFIX}"/etc/zsh \
		--enable-runhelpdir="${EPREFIX}"/usr/share/zsh/"${PVPATH}"/help \
		--enable-fndir="${EPREFIX}"/usr/share/zsh/"${PVPATH}"/functions \
		--enable-site-fndir="${EPREFIX}"/usr/share/zsh/site-functions \
		--enable-function-subdirs \
		--with-tcsetpgrp \
		$(use_enable maildir maildir-support) \
		$(use_enable pcre) \
		$(use_enable caps cap) \
		$(use_enable unicode multibyte) \
		$(use_enable gdbm ) \
		"${myconf[@]}"

	if use static ; then
		# compile all modules statically, see Bug #27392
		# removed cap and curses because linking failes
		sed -e "s,link=no,link=static,g" \
			-e "/^name=zsh\/cap/s,link=static,link=no," \
			-e "/^name=zsh\/curses/s,link=static,link=no," \
			-i "${S}"/config.modules || die
		if ! use gdbm ; then
			sed -i '/^name=zsh\/db\/gdbm/s,link=static,link=no,' \
				"${S}"/config.modules || die
		fi
	fi
}

src_compile() {
	default
	! ${LIVE} || ! use doc || emake -C Doc everything
	! ${LIVE} || fix_soelim
}

src_test() {
	addpredict /dev/ptmx
	local i
	for i in C02cond.ztst V08zpty.ztst X02zlevi.ztst Y01completion.ztst Y02compmatch.ztst Y03arguments.ztst ; do
		rm "${S}"/Test/${i} || die
	done
	emake check
}

zcompile_dirs() {
	use compile || return 0
	einfo "compiling modules"
	local i
	i="${S}/Src/zshpaths.h"
	test -f "${i}" || die "cannot find ${i}"
	# We need this directory also in pkg_postinst
	FPATH_DIR="$(sed -n -e \
		's/^#define FPATH_DIR .*\"\(.*\)\".*$/\1/p' -- "${i}" 2>/dev/null)" \
		|| FPATH_DIR=
	[ -n "${FPATH_DIR}" ] || die "cannot parse ${i}"
	pushd -- "${ED}" >/dev/null || die
	test -d ".${FPATH_DIR}" || die "parsing ${i} gave strange result ${FPATH_DIR}"
	find ".${FPATH_DIR}" -type d -exec "${ED}bin/zsh" -fc 'setopt nullglob
for i
do	a=(${i}/*(.))
	[[ ${#a} -eq 0 ]] && continue
	echo "Compiling ${i#.}.zwc"
	zcompile -U -M ${i}.zwc ${a} || exit
done' zsh '{}' '+' || die 'compiling failed. If you are cross-compiling set USE=-compile'
	popd >/dev/null
}

touch_zwc() {
	use compile || return 0
	einfo "touching *.zwc files"
	# Make a sanity check that variables are preserved after zcompile_dirs:
	# If the package mangler is not faulty, this *must* succeeed.
	[ -n "${FPATH_DIR}" ] && test -d "${FPATH_DIR}" || die "strange FPATH_DIR"
	# Now the actual action
	find "${EPREFIX}${FPATH_DIR}" -type f -name '*.zwc' \
		-exec "$(command -v touch)" -- '{}' '+'
}

src_install() {
	# install.info needs texinfo unless the doc tarball is available
	emake DESTDIR="${ED}" install $(usex doc "install.info" "")

	insinto /etc/zsh
	doins "${T}"/zprofile

	keepdir /usr/share/zsh/site-functions
	insinto /usr/share/zsh/"${PVPATH}"/functions/Prompts
	newins "${FILESDIR}"/prompt_gentoo_setup-1 prompt_gentoo_setup

	local i

	# install miscellaneous scripts (bug #54520)
	sed -e "s:/usr/local/bin/perl:${EPREFIX}/usr/bin/perl:g" \
		-e "s:/usr/local/bin/zsh:${EPREFIX}/bin/zsh:g" \
		-i "${S}"/{Util,Misc}/* || die
	for i in Util Misc ; do
		insinto /usr/share/zsh/"${PVPATH}"/${i}
		doins ${i}/*
	done

	# install header files (bug #538684)
	insinto /usr/include/zsh
	doins config.h Src/*.epro
	for i in Src/{zsh.mdh,*.h} ; do
		sed -e 's@\.\./config\.h@config.h@' \
			-e 's@#\(\s*\)include "\([^"]\+\)"@#\1include <zsh/\2>@' \
			-i "${i}"
		doins "${i}"
	done

	dodoc ChangeLog* META-FAQ NEWS README config.modules
	readme.gentoo_create_doc

	if use doc ; then
		pushd "${WORKDIR}/${PN}-${PV%_*}" >/dev/null
		dodoc Doc/zsh.{dvi,pdf}
		docinto html
		dodoc Doc/*.html
		popd >/dev/null
	fi

	docinto StartupFiles
	dodoc StartupFiles/z*

	zcompile_dirs

	rm -vf -- "${ED}"/bin/zsh?*
}

pkg_postinst() {
	readme.gentoo_print_elog
	touch_zwc
}
