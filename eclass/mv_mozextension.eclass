# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: mv_mozextension.eclass
# @MAINTAINER:
# Martin Väth <martin@mvath.de>
# @BLURB: This eclass provides functions to install mozilla extensions
# @DESCRIPTION:
# The eclass is based on mozextension.eclass with many extensions.
# 1. It has some compatibility fixes in xpi_install/xpi_unpack.
# 2. A default src_unpack function is defined; set FILENAME to the archive name.
#    If FILENAME is unset or empty, the last part of the last SRC_URI is used.
# 3. Default functions for installation for all mozilla type browsers.

# @ECLASS-VARIABLE: MV_MOZ_MOZILLAS
# @DESCRIPTION:
# If this variables is set to the empty value, no default install functions
# are defined. Otherwise, the value of this variable should be
# "firefox seamonkey" (default)
# or a subset of these.
# The eclass will then install the extension for all these mozillas,
# set corresponding dependencies and print corresponding messages.
: ${MV_MOZ_MOZILLAS=firefox seamonkey}

inherit eutils multilib

case ${EAPI:-0} in
[01234])
	die "EAPI ${EAPI} no longer supported by ${ECLASS}";;
esac

MV_MOZ_IUSE=
RDEPEND='|| ('
case ${MV_MOZ_MOZILLAS} in
*fire*)
	MV_MOZ_IUSE="${MV_MOZ_IUSE}${MV_MOZ_IUSE:+ }firefox firefox-bin"
	RDEPEND="${RDEPEND}
	firefox? ( >=www-client/firefox-21 )
	firefox-bin? ( >=www-client/firefox-bin-21 )"
esac
case ${MV_MOZ_MOZILLAS} in
*sea*)
	MV_MOZ_IUSE="${MV_MOZ_IUSE}${MV_MOZ_IUSE:+ }seamonkey seamonkey-bin"
	RDEPEND="${RDEPEND}
	seamonkey? ( www-client/seamonkey )
	seamonkey-bin? ( www-client/seamonkey-bin )"
esac
RDEPEND="${RDEPEND} )"
IUSE=${MV_MOZ_IUSE}
REQUIRED_USE="|| ( ${MV_MOZ_IUSE} )"

DEPEND='app-arch/unzip'

mv_mozextension_src_unpack() {
	local i
	if [ -z "${FILENAME}" ]
	then	for i in ${SRC_URI}
		do	FILENAME=${i##*/}
		done
	fi
	xpi_unpack "${FILENAME}"
}

mv_mozextension_src_prepare() {
	epatch_user
}

EXPORT_FUNCTIONS src_unpack src_prepare

mv_mozextension_src_install() {
	local b e
	b="${EPREFIX}/usr/$(get_libdir)"
	e="${EPREFIX}/opt"
	mv_mozextension_install firefox "${b}/firefox/browser/extensions"
	mv_mozextension_install firefox-bin "${e}/firefox/browser/extensions"
	mv_mozextension_install seamonkey "${b}/seamonkey/extensions"
	mv_mozextension_install seamonkey-bin "${e}/seamonkey/extensions"
}

[ -z "${MV_MOZ_MOZILLAS}" ] || EXPORT_FUNCTIONS src_install

xpi_unpack() {
	local xpi srcdir u

	# Not gonna use ${A} as we are looking for a specific option being passed to function
	# You must specify which xpi to use
	[ ${#} -eq 0 ] && die \
		"Nothing passed to the ${FUNCNAME} command. Please pass which xpi to unpack"

	test -d "${S}" || mkdir "${S}" || die
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

		test -s "${srcdir}${xpi}" ||  die "${xpi} does not exist"

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

xpi_install() {
	local d x

	# You must tell xpi_install which dir to use
	[ ${#} -eq 1 ] || die "${FUNCNAME} takes exactly one argument. Please specify the directory"

	x=${1}
	# determine id for extension
	d='{ /\<\(em:\)*id\>/!d; s/.*[\">]\([^\"<>]*\)[\"<].*/\1/; p; q }'
	d=$(sed -n -e '/install-manifest/,$ '"${d}" "${x}"/install.rdf) \
		&& [ -n "${d}" ] || die 'failed to determine extension id'
	: ${MOZILLA_EXTENSIONS_DIRECTORY:="${MOZILLA_FIVE_HOME}/extensions"}
	d="${MOZILLA_EXTENSIONS_DIRECTORY}/${d}"
	test -d "${D}${d}" || dodir "${d}" || die "failed to create ${d}"
	cp -RPl -- "${x}"/* "${D}${d}" || {
		ewarn 'Failed to hardlink extension. Falling back to USE=copy-extensions'
		insinto "${d}" && doins -r "${x}"/*
	} || die 'failed to copy extension'
}

# This function is called by mv_mozextension_src_install
# and should be overridden if the paths do not match:
# It just should call xpi_install with the correct argument(s)
xpi_install_dirs() {
	local d
	for d in "${S}"/*
	do	[ -n "${d}" ] && test -d "${d}" && xpi_install "${d}"
	done
}

mv_mozextension_install() {
	local MOZILLA_EXTENSIONS_DIRECTORY
	has "${1}" ${MV_MOZ_IUSE} && use "${1}" || return 0
	MOZILLA_EXTENSIONS_DIRECTORY=${2}
	xpi_install_dirs
}
