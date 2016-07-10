# Copyright 2016 Gentoo Foundation
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
#	moz_install
# }

case ${EAPI:-0} in
[0-5])
	die "EAPI ${EAPI} not supported by ${ECLASS}";;
esac

# @FUNCTION: moz_defaults
# @USAGE: [-c|-C|-n] [--] [<browser>] [<browser>] [...]
# @DESCRIPTION:
# This is just a convenience wrapper for moz_variables [args]; moz_phases [args]
moz_defaults() {
	moz_variables "${@}"
	moz_phases "${@}"
}

# @FUNCTION: moz_variables
# @USAGE: [-c|-C|-n] [--] [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Sets the variables DEPEND, RDEPEND, IUSE, REQUIRED_USE for browsers.
# browser is firefox or seamonkey and implies source or binary version.
# If no browser is specified, all are assumed.
# If option -C or -n is specified, IUSE=compressed is not default/added.
moz_variables() {
	local o opt
	o=
	OPTIND=1
	while getopts 'cCn' opt
	do	o="-${opt}"
	done
	shift $(( ${OPTIND} - 1 ))
	DEPEND=${MOZ_DEPEND}
	RDEPEND=$(moz_rdepend "${@}")
	IUSE=$(moz_iuse ${o} "${@}")
	REQUIRED_USE=$(moz_required_use "${@}")
}

# @FUNCTION: moz_phases
# @USAGE: [-c|-C|-n] [--] [ignored args]
# @DESCRIPTION:
# Defines src_unpack and src_install to call only moz_unpack and moz_install.
# If option -c or -n is specified, IUSE is ignored with compression on/off
moz_phases() {
	local o opt
	o=
	OPTIND=1
	while getopts 'cCn' opt
	do	case ${opt} in
		c)
			o=" -c";;
		n)
			o=" -n";;
		C)
			o=;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	eval "src_unpack() {
moz_unpack${o}
}
	src_install() {
moz_install${o}
}"
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
			rdep=${rdep}${rdep:+\ }"browser_${i}? ( www-client/${i} )"
			c=${c}a;;
		esac
		case ${mode} in
		*b*)
			rdep=${rdep}${rdep:+\ }"browser_${i}-bin? ( www-client/${i}-bin )"
			c=${c}a;;
		esac
	done
	[ -n "${c}" ] || die "args must be [firefox|palemoon|seamonkey][-source|-bin]"
	[ "${c}" = a ] && echo "${rdep}" || echo "|| ( ${rdep} )"
}

# @FUNCTION: moz_iuse
# @USAGE: [-c|-C|-n] [--] [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs IUSE expression appropriate for browsers.
# browser is [firefox|palemoon|seamonkey][-source|-bin] (no specified = all).
# If option -C or -n is specified, IUSE=compressed is not default/added.
moz_iuse() {
	local iuse i opt
	iuse="+compressed"
	OPTIND=1
	while getopts 'cCn' opt
	do	case ${opt} in
		c)	iuse="+compressed";;
		C)	iuse="compressed";;
		n)	iuse=;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	[ ${#} -ne 0 ] || set -- "firefox palemoon seamonkey"
	for i in firefox palemoon seamonkey
	do	case "${*}" in
		*"${i}"?source*)
			iuse=${iuse}${iuse:+\ }"browser_${i}";;
		*"${i}"?bin*)
			iuse=${iuse}${iuse:+\ }"browser_${i}-bin";;
		*"${i}"*)
			iuse=${iuse}${iuse:+\ }"browser_${i} browser_${i}-bin";;
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
	set -- $(moz_iuse -n "${@}")
	[ ${#} -lt 2 ] && echo "${*}" || echo "|| ( ${*} )"
}

# @FUNCTION: moz_unpack
# @USAGE: [-c|-C|-n] [--] <file> <file> [...]
# @DESCRIPTION:
# Unpack xpi files. If no file is specified, ${A} is used.
# Option -c means compression mode (partial unpack), independent of USE
# Option -n means no-compression mode (full unpack), independent of USE
moz_unpack() {
	local xpi srcdir xpiname archiv comp opt
	comp=
	OPTIND=1
	while getopts 'cn' opt
	do	case ${opt} in
		c)	comp=:;;
		n)	comp=false;;
		C)	comp=;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	if [ -z "${comp}" ] && in_iuse compressed && ! use compressed
	then	comp=false
	else	comp=:
	fi
	[ ${#} -ne 0 ] || set -- ${A}
	test -d "${S}" || mkdir "${S}" || die "cannot create ${S}"
	for xpi
	do	einfo "Unpacking ${xpi} to ${S} (partially)"
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
			:;;
		*)
			einfo "unpack ${xpi}: file format not recognized. Ignoring.";;
		esac
		archiv="${S}/${xpiname}.xpi"
		einfo "Copying ${xpi} to ${archiv}"
		cp -p -- "${srcdir}${xpi}" "${archiv}" || die
		chmod 644 -- "${archiv}" || die
		mkdir -- "${S}/${xpiname}" || die
		cd -- "${S}/${xpiname}" || die
		if ${comp}
		then	einfo "Extracting install.rdf for ${xpiname}"
			unzip -qo -- "${archiv}" install.rdf || die
		else	einfo "Unpacking ${xpiname}"
			unzip -qo -- "${archiv}" || die
			chmod -R a+rX,u+w,go-w -- "${S}/${xpiname}" || die
		fi
	done
}

# @FUNCTION: moz_getid
# @USAGE: <variable> [<path/to/[install.rdf]>]
# @DESCRIPTION:
# Extracts the package id from the install.rdf manifest
# and stores the result in the variable.
moz_getid() {
	local var res sub rdf
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	var=${1}
	rdf=${2:-.}
	rdf=${rdf%/}
	! test -d "${rdf}" || rdf=${rdf}"/install.rdf"
	test -f "${rdf}" || die "${rdf} is not an ordinary file"
	sub='{ /\<\(em:\)*id\>/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }'
	res=$(sed -n -e '/install-manifest/,$ '"${sub}" -- "${rdf}") || res=
	[ -n "${res}" ] || die "failed to determine id from ${rdf}"
	eval ${var}=\${res}
}

# @FUNCTION: moz_install_to_dir
# @USAGE: [-n] [--] <extension-directory> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dir.xpi as (id) of extension-directory,
# the name of the id being determined from ${dir}/install.rdf.
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means nocompression mode: Install dir instead of dir.xpi.
moz_install_to_dir() {
	local id dest i have comp opt
	comp=:
	OPTIND=1
	while getopts 'cn' opt
	do	case ${opt} in
		c)	comp=:;;
		n)	comp=false;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	dest=${1%/}
	shift
	dodir "${dest}"
	[ ${#} -gt 0 ] || set -- "${S}"/*
	have=false
	for i
	do	[ -n "${i}" ] && test -d "${i}" || continue
		have=:
		moz_getid id "${i}"
		if ${comp}
		then	ln -- "${i}.xpi" "${ED}${dest}/${id}.xpi" \
			|| cp -- "${i}.xpi" "${ED}${dest}/${id}.xpi" || die
		else	id=${dest}/${id}
			dodir "${id}" || die "failed to create ${id}"
			cp -RPl -- "${i}"/* "${ED}${id}" || {
				insinto "${id}" && doins -r "${i}"/*
			} || die
		fi
	done
	${have} || die "no directory found in argument list"
}

# @FUNCTION: moz_install_for_browser
# @USAGE: [-n] [--] <browser> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs.xpi for browser ({firefox,palemoon,seymonkey}{,-bin}).
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means nocompression mode: Install dirs instead of dirs.xpi.
moz_install_for_browser() {
	local dest firefox palemoon seamonkey o opt
	o=
	OPTIND=1
	while getopts 'cn' opt
	do	o="-${opt}"
	done
	shift $(( ${OPTIND} - 1 ))
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
	moz_install_to_dir ${o} -- "${dest}" "${@}"
}

# @FUNCTION: moz_install
# @USAGE: [-c|-n|-C] [--] <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs/dirs.xpi into appropriate destinations, depending on USE.
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means to install dir instead of dirs.xpi, independent on USE.
# Option -c means to install dir.xpi, independent on USE.
moz_install() {
	local i o opt
	o="?"
	OPTIND=1
	while getopts 'cCn' opt
	do	case ${opt} in
		c)	o=;;
		n)	o="-n";;
		C)	o="?";;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	if [ "${o}" = "?" ] && in_iuse compressed && ! use compressed
	then	o="-n"
	else	o=
	fi
	for i in firefox firefox-bin palemoon palemoon-bin seamonkey seamonkey-bin
	do	if in_iuse "browser_${i}" && use "browser_${i}"
		then	moz_install_for_browser ${o} -- "${i}" "${@}"
		fi
	done
}
