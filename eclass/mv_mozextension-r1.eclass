# Copyright 2015-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mv_mozextension-r1.eclass
# @MAINTAINER:
# Martin Väth <martin@mvath.de>
# @SUPPORTED_EAPIS: 6 7
# @BLURB: This eclass provides functions to install mozilla extensions
# @DESCRIPTION:
# The eclass is based on mozextension.eclass with many extensions
# and compatiblity fixes.
# @EXAMPLE:
# @CODE
# inherit mv_mozextension-r1
#
# moz_defaults firefox seamonkey # no arguments mean all browsers
#
# @CODE
# inherit mv_mozextension-r1
#
# MOZ="<firefox-57 seamonkey"
# BDEPEND=${MOZ_BDEPEND}
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
# @USAGE: [-c|-C|-n] [-i id] [--] [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Sets the variables DEPEND, RDEPEND, IUSE, REQUIRED_USE for browsers.
# browser is (firefox|seamonkey) and implies source or binary version.
# If no browser is specified, all are assumed.
# If option -C or -n is specified, IUSE=compressed is not default/added.
moz_variables() {
	local o opt
	o=
	OPTIND=1
	while getopts 'cCni:' opt
	do	case ${opt} in
		[cCn])
			o="-${opt}";;
		*)
			:;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	case ${EAPI} in
	6)
		DEPEND=${MOZ_BDEPEND};;
	*)
		BDEPEND=${MOZ_BDEPEND};;
	esac
	RDEPEND=$(moz_rdepend "${@}")
	IUSE=$(moz_iuse ${o} "${@}")
	REQUIRED_USE=$(moz_required_use "${@}")
}

# @FUNCTION: moz_phases
# @USAGE: [-cCn] [-i id] [--] [ignored args]
# @DESCRIPTION:
# Defines src_unpack and src_install to call only moz_unpack and moz_install.
moz_phases() {
	local o
	o=()
	OPTIND=1
	while getopts 'cCni:' opt
	do	case ${opt} in
		[cCn])
			o+=("-${opt}");;
		*)
			o+=("-${opt}" "${OPTARG}");;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	set -- "${o[@]}"
	if [ $# -eq 0 ]
	then	quoteargs=
	else	quoteargs=`printf ' %q' "$@"`
	fi
	eval "src_unpack() {
moz_unpack$quoteargs
}
	src_install() {
moz_install$quoteargs
}"
}

# @ECLASS-VARIABLE: MOZ_BDEPEND
# @DESCRIPTION:
# This is an eclass-generated depend expression needed for moz_unpack to work
MOZ_BDEPEND='app-arch/unzip'

# @FUNCTION: moz_split_browser
# @USAGE: <browser>
# @DESCRIPTION:
# browser is one of [operator](firefox|seamonkey)[-source|-bin][*].
# The function outputs the "browser[-source|-bin]" part
moz_split_browser() {
	local browser
	for browser in firefox seamonkey
	do	case ${1} in
		*"${browser}"?source*)
			echo "${browser}-source"
			return;;
		*"${browser}"?bin*)
			echo "${browser}-bin"
			return;;
		*"${browser}"*)
			echo "${browser}"
			return;;
		esac
	done
	die "args must be [operator](firefox|seamonkey)[-source|-bin][*]"
}

# @FUNCTION: moz_split_operator
# @USAGE: <browser>
# @DESCRIPTION:
# browser is one of [operator](firefox|seamonkey)[-source|-bin][*].
# The function outputs the "[operator]" part
moz_split_operator() {
	local browser operator
	for browser in firefox seamonkey
	do	case ${1} in
		*"${browser}"*)
			operator=${1%%"${browser}"*}
			echo "${operator}"
			return;;
		esac
	done
	die "args must be [operator](firefox|seamonkey)[-source|-bin][*]"
}

# @FUNCTION: moz_split_rest
# @USAGE: <browser>
# @DESCRIPTION:
# browser is one of [operator](firefox|seamonkey)[-source|-bin][*].
# The function outputs the "[*]" part
moz_split_rest() {
	local front rest
	for front in source bin firefox seamonkey
	do	case ${1} in
		*"${front}"*)
			rest=${1#*"${front}"}
			echo "${rest}"
			return;;
		esac
	done
	die "args must be [operator](firefox|seamonkey)[-source|-bin][*]"
}

# @FUNCTION: moz_atom
# @USAGE: <browser> <operator> <rest>
# @DESCRIPTION:
# Prints the atom/subexpression used in RDEPEND for the corresponding browser,
# e.g. [operator]www-client/firefox-bin[rest]
# browser is one of (firefox|seamonkey)(-source|-bin)
# If nothing is printed, the output of
# "moz_atom_default <browser> <operator> <rest>"
# is used (see below).
# moz_atom is meant to be defined by the ebuild if non-defaults are used.
# @DEFAULT_UNSET

# @FUNCTION: moz_atom_default
# @USAGE: <browser> <operator> <rest>
# @DESCRIPTION:
# Prints the atom/subexpression used in RDEPEND for the corresponding browser,
# when moz_atom is not defined or prints nothing.
# browser is one of (firefox|seamonkey)(-source|-bin).
moz_atom_default() {
	echo "${2}www-client/${1%?source}${3}"
}

# @FUNCTION: moz_rdepend
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs RDEPEND expression appropriate for browsers.
# browser is one of [operator](firefox|seamonkey)[-source|-bin][*]
# (none specified = all browsers)
# Note that moz_rdepend_atom (if defined by the ebuild) is used to calculate
# the expression.
moz_rdepend() {
	local arg rdep browser count modes mode atom useflag operator rest
	[ ${#} -ne 0 ] || set -- firefox seamonkey
	count=
	rdep=
	for arg
	do	browser=`moz_split_browser "${arg}"`
		operator=`moz_split_operator "${arg}"`
		rest=`moz_split_rest "${arg}"`
		modes="source bin"
		case ${browser} in
		*source*)
			browser=${browser%?source*}
			modes=source;;
		*bin*)
			browser=${browser%?bin*}
			modes=bin;;
		esac
		for mode in $modes
		do	atom=
			[ "$(type -t moz_atom)" != "function" ] || \
				atom=`moz_atom "${browser}-${mode}" "${operator}" "${rest}"`
			[ -n "$atom" ] || \
				atom=`moz_atom_default "${browser}-${mode}" "${operator}" "${rest}"`
			useflag=browser_${browser}
			[ "$mode" = "source" ] || useflag=${useflag}-${mode}
			rdep=${rdep}${rdep:+\ }"${useflag}? ( ${atom} )"
			count=${count}a
		done
	done
	[ "${count}" = a ] && echo "${rdep}" || echo "|| ( ${rdep} )"
}

# @FUNCTION: moz_iuse
# @USAGE: [-c|-C|-n] [--] [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs IUSE expression appropriate for browsers.
# browser is [opertator](firefox|seamonkey)[-source|-bin][*]
# (none specified = all browsers).
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
	[ ${#} -ne 0 ] || set -- firefox seamonkey
	for i in firefox seamonkey
	do	case "${*}" in
		*"${i}"?source*)
			iuse=${iuse}${iuse:+\ }"browser_${i}";;
		*"${i}"?bin*)
			iuse=${iuse}${iuse:+\ }"browser_${i}-bin";;
		*"${i}"*)
			iuse=${iuse}${iuse:+\ }"browser_${i} browser_${i}-bin";;
		esac
	done
	[ -n "${iuse}" ] || die "args must be [operator](firefox|seamonkey)[-source|-bin][*]"
	echo "${iuse}"
}

# @FUNCTION: moz_required_use
# @USAGE: [<browser>] [<browser>] [...]
# @DESCRIPTION:
# Outputs REQUIRED_USE expression appropriate for browsers.
# browser is [operator](firefox|seamonkey)[-source|-bin][*]
# (none specified = all browsers).
moz_required_use() {
	set -- $(moz_iuse -n "${@}")
	[ ${#} -lt 2 ] && echo "${*}" || echo "|| ( ${*} )"
}

# @FUNCTION: moz_unpack
# @USAGE: [-c|-C|-n] [-i id] [--] <file> <file> [...]
# @DESCRIPTION:
# Unpack xpi files. If no file is specified, ${A} is used.
# Option -c means compression mode (partial unpack), independent of USE
# Option -n means no-compression mode (full unpack), independent of USE
moz_unpack() {
	local xpi srcdir xpiname archiv comp opt id
	id=false
	comp=
	OPTIND=1
	while getopts 'Ccni:' opt
	do	case ${opt} in
		c)	comp=:;;
		n)	comp=false;;
		C)	comp=;;
		i)	id=:;;
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
		then	if ! ${id}
			then	einfo "Extracting manifest.json for ${xpiname}"
				unzip -qo -- "${archiv}" manifest.json
				# Do not die on failure: One of the two files will not exist
			fi
		else	einfo "Unpacking ${xpiname}"
			unzip -qo -- "${archiv}" || die
			chmod -R a+rX,u+w,go-w -- "${S}/${xpiname}" || die
		fi
	done
}

# @FUNCTION: moz_getid
# @USAGE: <variable> [<path/to/manifest.json>]
# @DESCRIPTION:
# Extracts the package id from the manifest.json
# and stores the result in the variable.
moz_getid() {
	local var res sub dir file
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	var=${1}
	dir=${2:-.}
	dir=${dir%/}
	test -d "${dir}" || die "moz_getid: argument must be a directory"
	file=${dir}/manifest.json
	test -f "${file}" || die "cannot find ${file}"
	sub='/^[[:space:]]*["'\'']gecko["'\''][[:space:]]*:/,/\}/s/'
	sub=${sub}'^[[:space:]]*["'\'']id["'\''][[:space:]]*:[[:space:]]*'
	sub=${sub}'["'\'']\(.*\)["'\''][[:space:]]*,\?[[:space:]]*$/\1/p'
	res=$(sed -n -e "${sub}" -- "${file}") || res=
	[ -n "${res}" ] || die "failed to determine id from ${file}"
	eval ${var}=\${res}
}

# @FUNCTION: moz_install_to_dir
# @USAGE: [-n] [-i id] [--] <extension-directory> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dir.xpi as (id) of extension-directory.
# If -i is not passed it is determined from ${dir}/manifest.json
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means nocompression mode: Install dir instead of dir.xpi.
moz_install_to_dir() {
	local id dest i have comp opt
	comp=:
	id=
	OPTIND=1
	while getopts 'cni:' opt
	do	case ${opt} in
		i)	id=${OPTARG};;
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
		[ -n "${id}" ] || moz_getid id "${i}"
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
# @USAGE: [-n] [-i id] [--] <browser> <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs.xpi for browser.
# browser is [operator](firefox|seymonkey)[-source|-bin][*]
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means nocompression mode: Install dirs instead of dirs.xpi.
moz_install_for_browser() {
	local dest firefox seamonkey o opt
	o=()
	OPTIND=1
	while getopts 'cni:' opt
	do	case ${opt} in
		[cn])
			o+=("-$opt");;
		*)
			o+=("-$opt" "${OPTARG}");;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	[ ${#} -ne 0 ] || die "${FUNCNAME} needs at least one argument"
	firefox="firefox/browser/extensions"
	seamonkey="seamonkey/extensions"
	case ${1} in
	*firefox*bin*)
		dest="/opt/${firefox}";;
	*firefox*)
		dest="/usr/$(get_libdir)/${firefox}";;
	*seamonkey?bin*)
		dest="/opt/${seamonkey}";;
	*seamonkey*)
		dest="/usr/$(get_libdir)/${seamonkey}";;
	*)
		die "unknown browser specified";;
	esac
	shift
	moz_install_to_dir "${o[@]}" -- "${dest}" "${@}"
}

# @FUNCTION: moz_install
# @USAGE: [-c|-n|-C] [-i id] [--] <dir> <dir> [...]
# @DESCRIPTION:
# Installs dirs/dirs.xpi into appropriate destinations, depending on USE.
# Arguments which are not directories are silently ignored.
# If arguments are specified, they must contain at least one directory.
# If no argument is specified, all directories from "${S}" are considered.
# Option -n means to install dir instead of dirs.xpi, independent on USE.
# Option -c means to install dir.xpi, independent on USE.
moz_install() {
	local i id o opt
	id=
	o="?"
	OPTIND=1
	while getopts 'cCni:' opt
	do	case ${opt} in
		c)	o=;;
		n)	o="-n";;
		C)	o="?";;
		i)	id=$OPTARG;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	if [ "${o}" = "?" ] && in_iuse compressed && ! use compressed
	then	o="-n"
	else	o=
	fi
	for i in firefox firefox-bin seamonkey seamonkey-bin
	do	if in_iuse "browser_${i}" && use "browser_${i}"
		then	moz_install_for_browser ${o} ${id:+-i "$id"} -- "${i}" "${@}"
		fi
	done
}
