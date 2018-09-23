# Copyright 2010-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: monotone.eclass
# @MAINTAINER:
# Martin Väth <martin@mvath.de>
# @AUTHOR:
# Martin Väth <martin@mvath.de>
# @SUPPORTED_EAPIS: 0 1 2 3 4 5 6 7
# @BLURB: The monotone eclass is written to fetch software sources from monotone repositories
# @DESCRIPTION:
# The monotone eclass provides functions to fetch software sources from
# monotone repositories.

# @ECLASS-VARIABLE: EMTN_STORE_DIR
# @DESCRIPTION:
# monotone sources store directory. Users may override this in /etc/make.conf
: ${EMTN_STORE_DIR:=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/mtn-src}

# @ECLASS-VARIABLE: EMTN_OFFLINE
# @DESCRIPTION:
# Set this variable to a non-empty value to disable the automatic updating of
# an monotone source tree. This is intended to be set by users.
: ${EMTN_OFFLINE:=${EVCS_OFFLINE}}

# @ECLASS-VARIABLE: EMTN_CMD
# @DESCRIPTION:
# monotone command with argument for database which must be '$db'
: ${EMTN_CMD:=mtn -d \"\$db\"}

# @ECLASS-VARIABLE: EMTN_PULL_CMD
# @DESCRIPTION:
# monotone pull command
: ${EMTN_PULL_CMD:=${EMTN_CMD} pull}

# @ECLASS-VARIABLE: EMTN_INIT_CMD
# @DESCRIPTION:
# monotone init command
: ${EMTN_INIT_CMD:=${EMTN_CMD} db init}

# @ECLASS-VARIABLE: EMTN_CO_CMD
# @DESCRIPTION:
# monotone checkout command
: ${EMTN_CO_CMD:=${EMTN_CMD} co}

# @ECLASS-VARIABLE: EMTN_PRINT_HEADS_CMD
# @DESCRIPTION:
# monotone command to print the revision of the heads
: ${EMTN_PRINT_HEADS_CMD:=${EMTN_CMD} automate heads}

# @ECLASS-VARIABLE: EMTN_DB
# @DESCRIPTION:
# Name of the database file where the local monotone repository is stored.
: ${EMTN_DB:=${PN}.db}

# @ECLASS-VARIABLE: EMTN_REPO_URI
# @DESCRIPTION:
# Name of the external monotone repository, e.g. foo.bar.org
: ${EMTN_REPO_URI:=}

# @ECLASS-VARIABLE: EMTN_GLOB
# @DESCRIPTION:
# Name of the glob for the external repository. Typically '*'
: ${EMTN_GLOB:=*}

# @ECLASS-VARIABLE: EMTN_MODULEPATH
# @DESCRIPTION:
# Name of the module to checkout
: ${EMTN_MODULEPATH:=${PN}}

# @ECLASS-VARIABLE: EMTN_MODULEDIR
# @DESCRIPTION:
# Name where the module should come. Empty means: basename of modulepath.
: ${EMTN_MODULEDIR:=}

# @ECLASS-VARIABLE: EMTN_REVISIONARGS
# @DESCRIPTION:
# Args for revision to checkout, e.g. "-r something"
# The special value "head" means to use the first head.
: ${EMTN_REVISIONARGS=head}

# @ECLASS-VARIABLE: EMTN_DISABLE_DEPENDENCIES
# @DESCRIPTION:
# Set this variable to a non-empty value to disable the automatic inclusion of
# monotone in dependencies.
: ${EMTN_DISABLE_DEPENDENCIES:=}

# @FUNCTION: monotone_fetch
# @USAGE: [repo_uri] [glob] [db]
# @DESCRIPTION:
# Fetch/update ${EMTN_STORE_DIR}/database from external uri (using glob)
# and copy it into ${S}.
# After this function, current working directory is ${S}.
#
# Can take three optional parameters:
#   repo_uri - a repository URI. If empty defaults to EMTN_REPO_URI.
#   glob     - The glob for URI. If empty defaults to EMTN_GLOB.
#   db       - the database filename. If empty defaults to EMTN_DB.
monotone_fetch() {
	local repo_uri glob db db_full
	repo_uri=${1:-${EMTN_REPO_URI}}
	glob=${2:-${EMTN_GLOB}}
	db=${3:-${EMTN_DB}}
	test -d "${EMTN_STORE_DIR}" || (
			addwrite /
			mkdir -p -- "/${EMTN_STORE_DIR}"
	)
	cd -P -- "${EMTN_STORE_DIR}" >/dev/null \
		|| die "cannot cd to ${EMTN_STORE_DIR}"

	if ! test -e "${db}"
	then	(
		addwrite "${PWD}"
		einfo "Initializing new ${db}" && \
		eval "${EMTN_INIT_CMD}" && \
		einfo "Fetching ${db} from remote ${repo_uri}" && \
		eval "${EMTN_PULL_CMD} \"\${repo_uri}\" \"\${glob}\""
	)
	elif [ -z "${EMTN_OFFLINE}" ]
	then	(
		addwrite "${PWD}"
		einfo "Updating ${db} from remote ${repo_uri}"
		eval "${EMTN_PULL_CMD}"
	)
	fi || die "Could not fetch/update ${db}"
	db_full="${EMTN_STORE_DIR}/${db}"
	einfo "Copying database ${db_full} ..."
	test -d "${S}" || mkdir -p -- "${S}" || die "mkdir ${S} failed"
	cd -- "${S}" >/dev/null
	cp -p -- "${db_full}" "${db}" || die "cp ${db_full} ${db} failed"
}

# @FUNCTION: monotone_co
# @USAGE: [db] [modulepath] [moduledir] [revisionargs]
# @DESCRIPTION:
# Unpack monotone sources from the local database.
#
# All parameters are optional:
#   db         - the database filename. If empty defaults to EMTN_DB.
#   modulepath - the name of the module to checkout.
#                If empty defaults to EMTN_MODULEPATH
#   moduledir  - the name of the directory in which the module should come.
#                If empty defaults to EMTN_MODULEDIR
#                If that is also empty defaults to basename of EMTN_MODULEPATH.
#   revisionargs - Args for the revision to checkout. If empty defaults to
#                EMTN_REVISIONARGS.
#                The special value "head" means to use the first head.
monotone_co() {
	local db modulepath moduledir r
	db=${1:-${EMTN_DB}}
	modulepath=${2:-${EMTN_MODULEPATH}}
	moduledir=${3:-${EMTN_MODULEDIR}}
	[ -z "${moduledir}" ] && moduledir=${modulepath##*/}
	if [ ${#} -gt 3 ]
	then	shift 3
	else	eval "set -- ${EMTN_REVISIONARGS}"
	fi
	if [ "${1}" = 'head' ]
	then	if r=`eval "${EMTN_PRINT_HEADS_CMD} \"\${modulepath}\"" \
		| tail -n1` && [ -n "${r}" ]
		then	set -- -r "${r}"
		else	set --
		fi
	fi
	if [ -n "${modulepath}" ]
	then	einfo "Checking out module ${modulepath}"
		eval "${EMTN_CO_CMD} -b \"\${modulepath}\" \"\${@}\" \"\${moduledir}\"" \
			|| die "checkout of ${modulepath} failed"
	else	einfo "Checking out module ${module}"
		eval "${EMTN_CO_CMD} \"\${@}\" \"\${moduledir}\"" \
			|| die "checkout of ${module} failed"
	fi
}

# @FUNCTION: monotone_finish
# @USAGE: [db]
# @DESCRIPTION:
# Call this when all modules are checked out: Removes the local database.
# The optional argument db defaults to EMTN_DB.
monotone_finish() {
	local db
	db=${1:-${EMTN_DB}}
	rm -- "${S}/${db}" || die "cannot remove ${S}/${db}"
}

# @FUNCTION: monotone_src_unpack
# @DESCRIPTION:
# Default src_unpack. Call monotone_fetch, monotone_co, monotone_finish
monotone_src_unpack() {
	monotone_fetch
	monotone_co
	monotone_finish
}

[ -n "${EMTN_DISABLE_DEPENDENCIES}" ] || case ${EAPI:-0} in
0|1|2|3|4|5|6)
	DEPEND='dev-vcs/monotone';;
*)
	BDEPEND='dev-vcs/monotone';;
esac

EXPORT_FUNCTIONS src_unpack
