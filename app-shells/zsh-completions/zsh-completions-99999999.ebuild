# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

case ${PV} in
99999999*)
	LIVE=:
	EGIT_REPO_URI="git://github.com/zsh-users/${PN}.git"
	inherit git-r3
	PROPERTIES="live"
	KEYWORDS=""
	SRC_URI="";;
*)
	LIVE=false
	#RESTRICT="mirror"
	TARBALL_VERSION='0.12.0'
	SRC_URI="https://github.com/zsh-users/${PN}/archive/${TARBALL_VERSION}.tar.gz -> ${PN}-${PV}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	S="${WORKDIR}/${PN}-${TARBALL_VERSION}"
esac

DESCRIPTION="Additional completion definitions for Zsh"
HOMEPAGE="https://gentoo.org/zsh-users/zsh-completions/"
LICENSE="ZSH"
SLOT="0"
if ${LIVE}
then	DEPEND=""
else	DEPEND=""
fi

IUSE=""
declare -a FILES
FILES=()
declare -A USEFILE FILEINDEX
USEFILE=()
FILEINDEX=()
used_value() {
	case ${!1} in
	'#'*)
		eval "${1}=\${${1}#?}"
		${LIVE};;
	'/'*)
		eval "${1}=\${${1}#?}"
		! ${LIVE};;
	esac
}
calculate_data() {
	local comp curr currfile used
	for comp
	do	curr="${comp%% *}"
		used_value curr || continue
		case ${curr} in
		'+'*)
			curr="completion_${curr#?}"
			IUSE="${IUSE}${IUSE:+ }+${curr}";;
		*)
			curr="completion_${curr}"
			IUSE="${IUSE}${IUSE:+ }${curr}";;
		esac
		for currfile in ${comp#* }
		do	used_value currfile
			used=${?}
			USEFILE["${currfile}"]="${curr}"
			[[ -z ${FILEINDEX["${currfile}"]} ]] || die "${currfile} listed twice"
			[ ${used} -ne 0 ] && continue
			FILEINDEX["${currfile}"]="${#FILES[@]}"
			FILES+=("${currfile}")
		done
	done
}
# Prepend # or / to mark only live/-nonlive categories or files
calculate_data \
	'+Android /_adb _android _emulator' \
	'+Google _google' \
	'+Unix #_chattr #_cheat  _cmake _dzen2 _logger #_lsattr /_nl #_openssl #_pixz /_ps #_rebar #_setcap _shutdown /_watch _xinput /_zfs' \
	'#+backup _tarsnap' \
	'+database _redis-cli _pgsql_utils' \
	'+dev _artisan _choc _console _geany /_gradle _phing _manage.py _mvn _pear _play _symfony _thor _vagrant _veewee' \
	'+disk #_scrub _sdd _smartmontools _srm' \
	'+distribute _celery /_envoy _fab #_fleetctl _glances _kitchen _knife _mina _mussh' \
	'+git _git-flow _git-pulls' \
	'#+go _go' \
	'#+gtk _gtk-launch' \
	'+hardware _optirun _perf _primus' \
	'+haskell /_cabal _ghc #_stack' \
	'+managers #_ansible #_ansible-galaxy #_ansible-playbook #_ansible-vault _bower /_brew #_cask _debuild _lein #_multirust _pactree _pkcon _port #_supervisorctl _yaourt' \
	'+multimedia _id3 _id3v2 _showoff' \
	'+net _dget _dhcpcd _httpie _iw /_mosh _rfkill _socat _ssh-copy-id #_ufw _vpnc _vnstat' \
	'+nfs _exportfs' \
	'+perl _cpanm' \
	'+python /_bpython _pygmentize _setup.py' \
	'+ruby _bundle _cap _ditz _gas _gem _gist _github _git-wtf _jekyll _lunchy _rails _rspec _rubocop _rvm' \
	'+search _ack _ag _jq #_jrnl' \
	'+session _atach _teamocil _tmuxinator _wemux' \
	'+subtitles _language_codes _periscope _subliminal' \
	'+virtualization /_boot2docker #_docker-machine #_rkt _virtualbox _virsh' \
	'+web _coffee _composer #_dad #_diana _docpad _drush _heroku #_hledger #_homestead _jonas _jmeter _jmeter-plugins _lunar _middleman #_mix _node _nvm _ralio /_salt _sbt _scala _svm'

src_prepare() {
	# Remove colliding completions
	if ! ${LIVE}
	then	mv src/_docker src/_pip . || die
	fi
	chmod a-x src/*
	eapply_user
}

src_install() {
	insinto /usr/share/zsh/site-functions
	local i j u
	for i in src/*
	do	j=${i#src/}
		u=${USEFILE["${j}"]}
		if [ -z "${u}" ]
		then	elog "installing unknown completion ${i#*/}"
				doins "${i}"
				continue
		fi
		! use "${u}" || doins "${i}"
		u=${FILEINDEX["${j}"]}
		FILES[${u}]=
	done
	for i in ${FILES[*]}
	do	elog "listed file ${i} not found"
	done
	dodoc README.md zsh-completions-howto.org
}

pkg_postinst() {
	elog
	elog "If you happen to compile your functions, you may need to delete"
	elog "~/.zcompdump{,.zwc} and recompile to make the new completions available"
	elog "to your shell."
	elog
}
