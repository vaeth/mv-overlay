# Copyright 2014-2020 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit linux-info pax-utils readme.gentoo-r1 systemd unpacker

# The following variable is only for testing purposes. Leave it to "false"
keep_original=false

DESCRIPTION="Sundtek MediaTV Pro III Drivers"
HOMEPAGE="http://support.sundtek.com/index.php/topic,2.0.html
http://sundtek.de/media/latest.phtml"
SRC_URI="http://www.sundtek.de/media/sundtek_installer_${PV}.sh"

RESTRICT="binchecks mirror strip"
LICENSE="sundtek"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ld-preload-env +ld-preload-file pax_kernel pulseaudio split-usr"
RDEPEND="!<sys-apps/openrc-0.13
pulseaudio? ( media-sound/pulseaudio )"
BDEPEND="pax_kernel? ( || ( sys-apps/elfix sys-apps/paxctl ) )"

DISABLE_AUTOFORMATTING="true"
DOC_CONTENTS="To initialize sundtek drivers during booting call
	rc-update add sundtek default          # for openrc
	systemctl enable sundtek-local.service # for systemd
You will probably need to adapt sundtek-local.service to your defaults
"

src_unpack() {
	local subdir a
	a="${S}/archives"
	mkdir -- "${S}" # "|| die" no necessary: test happens in cd
	mkdir -- "${a}"
	cd -- "${a}" || die "cannot cd to ${a}"
	bash -- "${DISTDIR}/${A}" -e || die "extracting failed"
	cd -- "${S}" || die
	if use amd64
	then	subdir=64bit
	elif use x86
	then	subdir=32bit
	else	die "This ebuild does not support the architecture.
Download from Sundtek directly, write your own ebuild, or send me patches."
	fi
	unpacker "${a}/${subdir}/installer.tar.gz" || die
	rm -rf -- "${a}" || die "cannot remove ${a}"
	cp -- \
		"${FILESDIR}"/sundtek.initd \
		"${FILESDIR}"/sundtek-local.service \
		"${FILESDIR}"/_mediaclient \
		"${FILESDIR}"/mediaclient.video \
		"${S}" || die
}

my_movlibdir() {
	local i
	for i in bin/*
	do	if test -d "${i}"
		then	mv "${i}" "${2}" || die
		fi
	done
}

src_prepare() {
	local mybinprefix mylibdir myinclude myinclsundtek mysystemd \
		myudev mypkgconfig mylirc myusr
	if ${keep_original}
	then	mylibdir="opt/lib"
			myinclude="opt/include"
			myusr=
	else	mylibdir="usr/$(get_libdir)"
			myinclude="usr/include"
			myusr="usr"
	fi
	mybinprefix="opt"
	mypkgconfig="usr/share/pkgconfig"
	myinclsundtek="${myinclude}/sundtek"
	if use split-usr
	then	myudev="lib/udev"
			myrootlib="lib"
	else	myudev="usr/lib/udev"
			myrootlib="usr/lib"
	fi
	mylirc="etc/lirc"
	umask 022
	if use pax_kernel
	then	pax-mark em opt/bin/mediasrv
		pax-mark e opt/bin/mediaclient
	fi
	mv opt 1 || die
	mkdir -p ${myusr} "${mybinprefix}" "${myrootlib}" "${mypkgconfig}" \
		"${mylirc}" 1/lib/pm-utils || die
	use pulseaudio || rm 1/bin/audio/libpulse.so || die
	mv 1/bin "${mybinprefix}" || die
	${keep_original} || mv 1/lib/pm 1/lib/pm-utils/sleep.d || die
	mv 1/lib "${mylibdir}" || die
	mv 1/include "${myinclude}" || die
	sed -e "s#/opt/lib#${EPREFIX}/${mylibdir}#" \
		-e "s#/opt/include#${EPREFIX}/${myinclsundtek}#" \
		-e "s#prefix=/opt#prefix=${EPREFIX}/${mybinprefix}#" \
		1/doc/libmedia.pc >"${mypkgconfig}/libmedia.pc" || die
	sed -i -e "s#/opt#${EPREFIX}/${mybinprefix}#" \
		etc/udev/rules.d/*.rules 1/doc/*.service sundtek.initd || die
	! test -r etc/udev/rules.d/80-mediasrv-eeti.rules ||
		sed -i -e "s/^\([^#]\)/#\1/" etc/udev/rules.d/80-mediasrv-eeti.rules \
		|| die
	rm etc/systemd/system/multi-user.target.wants/sundtek.service || die
	rmdir etc/systemd/system/multi-user.target.wants || die
	rmdir etc/systemd/system || die
	rmdir etc/systemd || die
	mv etc/udev/rules.d/80-mediasrv.rules etc/hal . || die
	mv etc/udev "${myudev}" || die
	mv 1/doc/hardware.conf 1/doc/sundtek.conf "${mylirc}" || die
	rm 1/doc/lirc_install.sh 1/doc/libmedia.pc || die
	mv 1/doc/*.service "${S}" || die
	mkdir "${S}/doc" && mkdir "${S}/doc/bin" || die
	mv 1/doc/README 1/doc/*.conf "${S}/doc" || die
	mv 1/doc/*.cgi "${S}/doc/bin" || die
	rm etc/ld.so.conf.d/optlib.conf && rmdir etc/ld.so.conf.d || die
	rmdir 1/doc || die "${S}/1/doc contains files not known to the ebuild"
	rmdir 1 || die "${S}/1 contains files not known to the ebuild"
	my_movlibdir "${mylibdir}"
	mkdir etc/revdep-rebuild || die
	echo "SEARCH_DIRS_MASK=\"${EPREFIX}/${mybinprefix}/bin/audio/libpulse.so\"" \
		>etc/revdep-rebuild/50-sundtek-tv
	if use ld-preload-file
	then	echo "/${mylibdir}/libmediaclient.so" >etc/ld.so.preload
	else	sed -i -e 's/preload:-NO/preload:-YES/' sundtek.initd
	fi
	sed -i -e "s'preload_lib:-/usr/lib'preload_lib:-/${mylibdir}'" sundtek.initd
	if use ld-preload-env
	then	mkdir etc/env.d
		echo "LD_PRELOAD=\"/${mylibdir}/libmediaclient.so\"" >etc/env.d/50sundtek-tv
	fi
	DOC_CONTENTS="${DOC_CONTENTS}
You have to put /${mylibdir}/libmediaclient.so into /etc/ld.so.preload
or to export LD_PRELOAD=\"/${mylibdir}/libmediaclient.so\"
before you start a multimedia applications like mplayer or mpv which should
be able to access the sundtek device.

This happens with USE=ld-preload-file or with ld-preload-env (in the global
environment), respectively.

However, such a global setting in some cases this gives warnings when
32-bit applications are used.

Thus, it might be a good idea to do it only locally by writing
corresponding wrapper scripts for those multimedia applications you
want to use with sundtek-tv.
"
	ln -sfn mediaclient.video mediaclient.audio
	ln -sfn mediaclient.video mediaclient.dvb
	default
}

src_install() {
	insinto /
	local i
	for i in etc lib64 lib32 lib usr opt
	do	test -d "${i}" && mv -- "${i}" "${ED}"
	done
	for i in "${ED}"/usr/bin "${ED}"/usr/$(get_libdir) "${ED}"/opt
	do	test -d "${i}" && chmod -R 755 "${i}"
	done
	if ! ${keep_original}
	then	newinitd sundtek.initd sundtek
		systemd_dounit *.service
		dodoc doc/README doc/*.conf
		mv -- doc/bin "${ED}/usr/share/doc/${PF}" || die
		docompress -x "/usr/share/doc/${PF}/bin"
	fi
	dobin mediaclient.video
	insinto /usr/bin
	doins mediaclient.dvb mediaclient.audio
	insinto /usr/share/zsh/site-functions
	doins _mediaclient
	readme.gentoo_create_doc
}

pkg_pretend() {
	local CONFIG_CHECK="~INPUT_UINPUT"
	check_extra_config
}

pkg_postinst() {
	einfo "Adding root to the audio group"
	usermod -aG audio root || {
		ewarn "Could not add root to the audio group."
		ewarn "You should do this manually if you have problems with sound"
	}
	false chmod 6111 "${EPREFIX}/opt/bin/mediasrv" || \
	elog "You might need to chmod 6111 ${EPREFIX}/opt/bin/mediasrv"
	if ! use ld-preload-file
	then	if use ld-preload-env
		then	elog "You might have to call env-update and source /etc/profile"
		else	elog "You need to set LD_PRELOAD locally, see"
				elog "${EPREFIX}/usr/share/doc/${PF}/README.gentoo*"
		fi
	fi
	readme.gentoo_print_elog
}
