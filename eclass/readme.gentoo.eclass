# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Temporary hack until gentoo fixes EAPI 6 support for readme.gentoo.eclass

if [[ -z ${_README_GENTOO_ECLASS} ]]; then
_README_GENTOO_ECLASS=1

case "${EAPI:-0}" in
	[0-3])
		die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}";;
	[45])
EXPORT_FUNCTIONS src_install pkg_postinst
readme.gentoo_src_install() {
	default
	readme.gentoo_create_doc
}
readme.gentoo_pkg_postinst() {
	readme.gentoo_print_elog
};;
esac

: ${README_GENTOO_SUFFIX:=""}

readme.gentoo_create_doc() {
	if [ -n "${DOC_CONTENTS}" ]
	then	if [ -n "${DISABLE_AUTOFORMATTING}" ]
		then	echo "${DOC_CONTENTS}" > "${T}"/README.gentoo
		else	(
			set -f
			echo -e ${DOC_CONTENTS} | fold -s -w 70 \
				| sed 's/[[:space:]]*$//' > "${T}"/README.gentoo
			)
		fi
	elif [ -f "${FILESDIR}/README.gentoo-${SLOT%/*}" ]
	then	cp "${FILESDIR}/README.gentoo-${SLOT%/*}" "${T}"/README.gentoo || die
	elif [ -f "${FILESDIR}/README.gentoo${README_GENTOO_SUFFIX}" ]
	then	cp "${FILESDIR}/README.gentoo${README_GENTOO_SUFFIX}" "${T}"/README.gentoo || die
	else	die "You are not specifying README.gentoo contents!"
	fi
	dodoc "${T}"/README.gentoo
	README_GENTOO_DOC_VALUE=$(< "${T}/README.gentoo")
}

readme.gentoo_print_elog() {
	if [ -z "${README_GENTOO_DOC_VALUE}" ]
	then	die "readme.gentoo_print_elog invoked without matching readme.gentoo_create_doc call!"
	elif ! [ -n "${REPLACING_VERSIONS}" ] || [ -n "${FORCE_PRINT_ELOG}" ]
	then	echo -e "${README_GENTOO_DOC_VALUE}" | while read -r ELINE; do elog "${ELINE}"; done
		elog ""
		elog "(Note: Above message is only printed the first time package is"
		elog "installed. Please look at ${EPREFIX}/usr/share/doc/${PF}/README.gentoo*"
		elog "for future reference)"
	fi
}

fi
