# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Temporary hack until gentoo fixes EAPI 6 support for bash-completion-r1.eclass

inherit toolchain-funcs

_bash-completion-r1_get_bashdir() {
	if $(tc-getPKG_CONFIG) --exists bash-completion &>/dev/null; then
		local path="$($(tc-getPKG_CONFIG) --variable=$1 bash-completion)"
		echo "${path#${EPREFIX}}"
	else
		echo $2
	fi
}

_bash-completion-r1_get_bashcompdir() {
	_bash-completion-r1_get_bashdir completionsdir /usr/share/bash-completion/completions
}

dobashcomp() (
		insinto "$(_bash-completion-r1_get_bashcompdir)"
		doins "${@}"
)
