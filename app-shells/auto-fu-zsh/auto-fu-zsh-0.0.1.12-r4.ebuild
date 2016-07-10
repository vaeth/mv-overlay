# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

pPN=${PN%-zsh}
mPN="${pPN}.zsh"
case ${PV} in
99999999*)
	LIVE=:
	EGIT_REPO_URI="git://github.com/hchbaw/${mPN}.git"
	EGIT_BRANCH="pu"
	inherit git-r3
	PROPERTIES="live"
	SRC_URI=""
	KEYWORDS="";;
*)
	LIVE=false
	RESTRICT="mirror"
	SRC_URI="https://github.com/hchbaw/${mPN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${mPN}-${PV}"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris";;
esac

DESCRIPTION="zsh automatic complete-word and list-choices: incremental completion"
HOMEPAGE="https://github.com/hchbaw/auto-fu.zsh/"

LICENSE="HPND"
SLOT="0"
IUSE="+compile"

DEPEND="compile? ( app-shells/zsh )"

DESTPATH="/usr/share/zsh/site-contrib/${mPN}"

generate_example() {
	echo "# Put something like the following into your ~/.zshrc

# First, we set sane options for the standard completion system:

autoload -Uz compinit is-at-least
compinit -D -u
zstyle ':completion:*' completer _complete
zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=1 # interactive
zstyle ':completion:*' accept-exact-dirs true
zstyle ':completion:*' path-completion false
if is-at-least 4.3.10
then	zstyle ':completion:*' format \"%B%F{yellow}%K{blue}%d%k%f%b\"
else	zstyle ':completion:*' format \"%B%d%b\"
fi

# Now we source ${PN}"
	if use compile
	then	echo ". ${DESTPATH}/${pPN}
auto-fu-install"
	else	echo ". ${DESTPATH}/${pPN}.zsh"
	fi
	echo "
# Finally, we configure ${PN}

zstyle ':auto-fu:highlight' input
zstyle ':auto-fu:highlight' completion bold,fg=blue
zstyle ':auto-fu:highlight' completion/one fg=blue
zstyle ':auto-fu:var' postdisplay # \$'\\n-azfu-'
#zstyle ':auto-fu:var' enable all
#zstyle ':auto-fu:var' track-keymap-skip opp
#zstyle ':auto-fu:var' disable magic-space
zle-line-init() auto-fu-init
zle -N zle-line-init
zle -N zle-keymap-select auto-fu-zle-keymap-select

# Starting a line with a space or tab or quoting the first word
# or escaping a word should deactivate auto-fu for that line/word.
# This is useful e.g. if auto-fu is too slow for you in some cases.
zstyle ':auto-fu:var' autoable-function/skiplines '[[:blank:]\\\\\"'\'']*'
zstyle ':auto-fu:var' autoable-function/skipwords '[\\\\]*'

# Let Ctrl-d successively remove tail of line, whole line, and exit
kill-line-maybe() {
	if ((\$#BUFFER > CURSOR))
	then	zle kill-line
	else	zle kill-whole-line
	fi
}
zle -N kill-line-maybe
bindkey '\C-d' kill-line-maybe

# Keep Ctrl-d behavior also when auto-fu is active
afu+orf-ignoreeof-deletechar-list() {
	afu-eof-maybe afu-ignore-eof zle kill-line-maybe
}
afu+orf-exit-deletechar-list() {
	afu-eof-maybe exit zle kill-line-maybe
}"
}

src_prepare() {
	(
		umask 022
		generate_example >"${S}"/zshrc-example
	)
	if ! ${LIVE}
	then
		# Make Ctrl-D return correctly.
		eapply "${FILESDIR}"/exit.patch
		# Reset color with "return":
		eapply "${FILESDIR}"/reset-color.patch
		# Make it work with older zsh versions:
		eapply "${FILESDIR}"/zsh-compatibility.patch
	fi
	eapply_user
}

src_compile() {
	! use compile || mPN="${mPN}" \
		zsh -c 'setopt extendedglob no_shwordsplit
source ${mPN}
auto-fu-zcompile ${PWD}/${mPN} ${PWD}' || die
}

src_install() {
	insinto "${DESTPATH}"
	doins "${mPN}"
	! use compile || doins "${pPN}" "${pPN}.zwc"
	dodoc zshrc-example README*
}
