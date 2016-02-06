# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: moz.eclass
# @MAINTAINER:
# Martin Väth <martin@mvath.de>
# @BLURB: This eclass provides functions to install mozilla extensions
# @DESCRIPTION:
# The eclass is based on mozextension.eclass with many extensions
# and compatiblity fixes.
# @EXAMPLE:
# @CODE
# inherit moz
#
# moz_defaults firefox palemoon seamonkey # no arguments mean all browsers
#
# @CODE
# inherit moz
#
# MOZ="firefox palemoon seamonkey"
# DEPEND=${MOZ_DEPEND}
# RDEPEND=$(moz_rdepend ${MOZ})
# IUSE=$(moz_iuse ${MOZ})
# REQUIRED_USE=$(moz_required_use ${MOZ})
#
# src_unpack() {
#	moz_unpack
# }
#
# src_install() {
#	default
#	moz_install
# }

case ${EAPI:-0} in
[0-5])
	die "EAPI ${EAPI} not supported by ${ECLASS}";;
esac

# @FUNCTION: moz_defaults
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# This is just a convenience wrapper for moz_variables [arguments]; moz_phases
moz_defaults() {
	moz_variables "${@}"
	moz_phases
}

# @FUNCTION: moz_variables
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Sets the variables DEPEND, RDEPEND, IUSE, REQUIRED_USE for browsers.
# browser is firefox or seamonkey and implies source or binary version.
# If no browser is specified, all are assumed.
moz_variables() {
	DEPEND=${MOZ_DEPEND}
	RDEPEND=$(moz_rdepend "${@}")
	IUSE=$(moz_iuse "${@}")
	REQUIRED_USE=$(moz_required_use "${@}")
}

# @FUNCTION: moz_phases
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Defines src_unpack and src_install to call only moz_unpack and moz_install
moz_phases() {
src_unpack() {
moz_unpack
}
src_install() {
default
moz_install
}
}

# @ECLASS-VARIABLE: MOZ_DEPEND
# @DESCRIPTION:
# This is an eclass-generated depend expression needed for moz_unpack to work
MOZ_DEPEND='app-arch/unzip'

# @FUNCTION: moz_rdepend
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs RDEPEND expression appropriate for browsers.
# browser is [firefox|palemoon|seamonkey][-source|-bin] (no specified = all)
moz_rdepend() {
	local rdep i c mode
	[ ${#} -ne 0 ] || set -- "firefox palemoon seamonkey"
	c=
	rdep=
	for i in firefox palemoon seamonkey
	do	mode=
		case ${*} in
		*"${i}"?source*)
			mode=s;;
		*"${i}"?bin*)
			mode=b;;
		*"${i}"*)
			mode=sb;;
		esac
		case ${mode} in
		*s*)
			rdep="${rdep}${rdep:+ }browser_${i}? ( www-client/${i} )"
			c=${c}a;;
		esac
		case ${mode} in
		*b*)
			rdep="${rdep}${rdep:+ }browser_${i}-bin? ( www-client/${i}-bin )"
			c=${c}a;;
		esac
	done
	[ -n "${c}" ] || die "args must be [firefox|palemoon|seamonkey][-source|-bin]"
	[ "${c}" = a ] && echo "${rdep}" || echo "|| ( ${rdep} )"
}

# @FUNCTION: moz_iuse
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs IUSE expression appropriate for browsers.
# browser is [firefox|palemoon|seamonkey][-source|-bin] (no specified = all)
moz_iuse() {
	local iuse i
	[ ${#} -ne 0 ] || set -- "firefox palemoon seamonkey"
	iuse=
	for i in firefox palemoon seamonkey
	do	case "${*}" in
		*"${i}"?source*)
			iuse="${iuse}${iuse:+ }browser_${i}";;
		*"${i}"?bin*)
			iuse="${iuse}${iuse:+ }browser_${i}-bin";;
		*"${i}"*)
			iuse="${iuse}${iuse:+ }browser_${i} browser_${i}-bin";;
		esac
	done
	[ -n "${iuse}" ] || die "args must be [firefox|palemoon|seamonkey][-source|-bin]"
	echo "${iuse}"
}

# @FUNCTION: moz_required_use
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs REQUIRED_USE expression appropriate for browsers.
# browser is [firefox|palemoon|seamonkey][-source|-bin] (no specified means all)
moz_required_use() {
	set -- $(moz_iuse "${@}")
	[ ${#} -lt 2 ] && echo "${*}" || echo "|| ( ${*} )"
}

# @FUNCTION: moz_unpack
# @USAGE: <file> <file> [...]
# @DESCRIPTION:
# Unpack xpi files. If no file is specified, ${A} is used.
moz_unpack() {
	local xpi srcdir xpiname

	[ ${#} -ne 0 ] || set -- ${A}
	test -d "${S}" || mkdir "${S}" || die "cannot create ${S}"
	for xpi
	do	einfo "Unpacking ${xpi} to ${S}"
		xpiname=${xpi%.*}
		xpiname=${xpiname##*/}

		case ${xpi} in
		./*|/*)
			srcdir=;;
		*)
			srcdir="${DISTDIR}/";;
		esac

		test -f "${srcdir}${xpi}" || die "${xpi} does not exist or is no file"

		case ${xpi##*.} in
		ZIP|zip|jar|xpi)
			mkdir -- "${S}/${xpiname}" && \
				cd -- "${S}/${xpiname}" && \
				unzip -qo -- "${srcdir}${xpi}" \
					|| die "failed to unpack ${xpi}"
			chmod -R a+rX,u+w,go-w -- "${S}/${xpiname}";;
		*)
			einfo "unpack ${xpi}: file format not recognized. Ignoring.";;
		esac
	done
}

# @FUNCTION: moz_install_to_dir
# @USAGE: <extension-directory> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs into a subdirectory (id) of extension-directory,
# the name of the id being determined from ${dir}/install.rdf
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
moz_install_to_dir() {
	local sub dest i s have
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	dest=${1}
	shift
	[ ${#} -gt 0 ] || set -- "${S}"/*
	s='{ /\<\(em:\)*id\>/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }'
	have=false
	for i
	do	[ -n "${i}" ] && test -d "${i}" || continue
		have=:
		test -r "${i}"/install.rdf && \
			sub=$(sed -n -e '/install-manifest/,$ '"${s}" "${i}"/install.rdf) \
				&& [ -n "${sub}" ] || die 'failed to determine id of ${i}'
		sub=${dest%/}/${sub}
		dodir "${sub}" || die "failed to create ${sub}"
		cp -RPl -- "${i}"/* "${ED}${sub}" || {
			insinto "${sub}" && doins -r "${x}"/*
		} || die "failed to install extension ${i}"
	done
	${have} || die "no directory found in argument list"
}

# @FUNCTION: moz_install_for_browser
# @USAGE: <browser> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs for browser (firefox firefox-bin seamonkey seamonkey-bin)
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
moz_install_for_browser() {
	local dest firefox palemoon seamonkey
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	firefox="firefox/browser/extensions"
	palemoon="palemoon/browser/extensions"
	seamonkey="seamonkey/extensions"
	case ${1} in
	firefox)
		dest="/usr/$(get_libdir)/${firefox}";;
	firefox?bin)
		dest="/opt/${firefox}";;
	palemoon)
		dest="/usr/$(get_libdir)/${palemoon}";;
	palemoon?bin)
		dest="/opt/${palemoon}";;
	seamonkey)
		dest="/usr/$(get_libdir)/${seamonkey}";;
	seamonkey?bin)
		dest="/opt/${seamonkey}";;
	*)
		die "unknown browser specified";;
	esac
	shift
	moz_install_to_dir "${dest}" "${@}"
}

# @FUNCTION: moz_install
# @USAGE: <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs into appropriate destinations, depending on USE.
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
moz_install() {
	local i
	for i in firefox firefox-bin palemoon palemoon-bin seamonkey seamonkey-bin
	do	if in_iuse "browser_${i}" && use "browser_${i}"
		then	moz_install_for_browser "${i}" "${@}"
		fi
	done
}
