# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Temporary hack until gentoo fixes EAPI 6 support for systemd.eclass

inherit toolchain-funcs

DEPEND="virtual/pkgconfig"

_systemd_get_unitdir() {
	if $(tc-getPKG_CONFIG) --exists systemd; then
		echo "$($(tc-getPKG_CONFIG) --variable=systemdsystemunitdir systemd)"
	else
		echo /usr/lib/systemd/system
	fi
}

systemd_get_unitdir() {
	has "${EAPI:-0}" 0 1 2 && ! use prefix && EPREFIX=
	echo "${EPREFIX}$(_systemd_get_unitdir)"
}

systemd_dounit() (
		insinto "$(_systemd_get_unitdir)"
		doins "${@}"
)

systemd_dotmpfilesd() {
	for f; do
		[[ ${f} == *.conf ]] \
			|| die 'tmpfiles.d files need to have .conf suffix.'
	done
	(
		insinto /usr/lib/tmpfiles.d/
		doins "${@}"
	)
}

systemd_with_unitdir() {
	local optname=${1:-systemdsystemunitdir}
	echo --with-${optname}="$(systemd_get_unitdir)"
}
