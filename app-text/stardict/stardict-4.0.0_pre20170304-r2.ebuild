# Copyright 1999-2025 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# NOTE: Even though the *.dict.dz are the same as dictd/freedict's files,
#       their indexes seem to be in a different format. So we'll keep them
#       seperate for now.

GNOME2_LA_PUNT=yes

inherit autotools flag-o-matic gnome2

DESCRIPTION="A international dictionary supporting fuzzy and glob style matching"
HOMEPAGE="http://stardict-4.sourceforge.net/
	https://github.com/huzheng001/stardict-3"
SRC_URI="https://dev.gentoo.org/~bircoph/distfiles/${P}.tar.xz
	pronounce? ( https://${PN}-3.googlecode.com/files/WyabdcRealPeopleTTS.tar.bz2 )
	qqwry? ( mirror://gentoo/QQWry.Dat.bz2 )"

LICENSE="CPL-1.0 GPL-3 LGPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ppc ppc64 ~riscv sparc x86"
IUSE="advertisement cal canberra debug dictdotcn espeak examples flite
fortune gnome gucharmap +htmlparse info man perl +powerwordparse
pronounce qqwry spell tools updateinfo +wikiparse +wordnet
+xdxfparse youdaodict"

RESTRICT="test"

S=${WORKDIR}/${P}

COMMON_DEPEND="
	>=dev-libs/glib-2.32:2
	dev-libs/libsigc++:2=
	canberra? ( media-libs/libcanberra[gtk3] )
	sys-libs/zlib:=
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/pango
	espeak? ( >=app-accessibility/espeak-1.29 )
	flite? ( app-accessibility/flite )
	gucharmap? ( gnome-extra/gucharmap:2.90= )
	spell? ( >=app-text/enchant-1.2:0= )
	tools? (
		dev-db/mysql-connector-c
		dev-libs/expat
		dev-libs/libpcre:=
		dev-libs/libxml2:=
	)
"
RDEPEND="${COMMON_DEPEND}
	info? ( sys-apps/texinfo )
	fortune? ( games-misc/fortune-mod )
	perl? ( dev-lang/perl )
"
DEPEND="${COMMON_DEPEND}
	gnome? (
		app-text/docbook-xml-dtd:4.3
		app-text/gnome-doc-utils
		dev-libs/libxslt
	)
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"

# docs are messy, installed manually below
DOCS=""

PATCHES=( "${FILESDIR}/${PN}-4.0.0_pre20160518-tabfile.patch" )

src_prepare() {
	# From Fedora
	# Remove unneeded sigc++ header files to make it sure
	# that we are using system-wide libsigc++
	# (and these does not work on gcc43)
	find dict/src/sigc++* -name \*.h -or -name \*.cc | xargs rm -f || die

	# Hackish workaround to make the legacy code work with >=gcc-15.
	# A cleaner approach would be to add/fix function declarations, but this
	# should better happen upstream
	append-cxxflags -Wno-deprecated-declarations -fpermissive

	# bug 604318
	sed -i '/AM_GCONF_SOURCE_2/d' dict/configure.ac || die

	if ! use gnome
	then	sed -i \
				-e '/GNOME_DOC_INIT/d' \
				-e '/help\/Makefile/d' \
				dict/configure.ac || die
			sed -i \
				-e 's/ help / /' \
				dict/Makefile.am || die
			sed -i \
				-e 's/\(libstardict_la_LIBADD = \)/\1 -lgmodule-2.0 /' \
				dict/src/lib/Makefile.am || die
	fi
	if ! use canberra
	then	sed -i \
				-e 's/ libcanberra libcanberra-gtk3//' \
				dict/configure.ac || die
			eapply "${FILESDIR}/${PN}-strip-canberra.patch"
	fi

	eapply_user
	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# Festival plugin crashes, bug 188684. Disable for now.
	# Gnome2 support is disabled due to deprecation request, bug 644346
	gnome2_src_configure \
		--disable-darwin-support \
		--disable-festival \
		--disable-gnome-support \
		--disable-gpe-support \
		--disable-maemo-support \
		--disable-schemas-install \
		--disable-scrollkeeper \
		$(use_enable advertisement) \
		$(use_enable cal) \
		$(use_enable debug) \
		$(use_enable dictdotcn) \
		$(use_enable espeak) \
		$(use_enable flite) \
		$(use_enable fortune) \
		$(use_enable gucharmap) \
		$(use_enable htmlparse) \
		$(use_enable info) \
		$(use_enable man) \
		$(use_enable powerwordparse) \
		$(use_enable qqwry) \
		$(use_enable spell) \
		$(use_enable tools) \
		$(use_enable updateinfo) \
		$(use_enable wikiparse) \
		$(use_enable wordnet) \
		$(use_enable xdxfparse) \
		$(use_enable youdaodict)
}

src_install() {
	gnome2_src_install

	dodoc AUTHORS ChangeLog README

	docinto dict
	dodoc dict/{AUTHORS,ChangeLog,README,TODO}
	dodoc dict/doc/{Documentation,FAQ,HowToCreateDictionary,Skins,StarDictFileFormat,TextualDictionaryFileFormat,Translation}
	dodoc -r dict/doc/wiki

	docinto lib
	dodoc lib/{AUTHORS,ChangeLog,README}

	if use examples; then
		docinto dict
		dodoc dict/doc/stardict-textual-dict*
		docompress -x /usr/share/doc/${PF}/dict
	fi

	if use qqwry; then
		insinto /usr/share/${PN}/data
		doins ../QQWry.Dat
	fi

	if use pronounce; then
		docinto WyabdcRealPeopleTTS
		dodoc ../WyabdcRealPeopleTTS/{README,readme.txt}
		rm -f ../WyabdcRealPeopleTTS/{README,readme.txt}
		insinto /usr/share
		doins -r ../WyabdcRealPeopleTTS
	fi

	# noinst_PROGRAMS with ${PN}_ prefix from tools/src/Makefile.am wrt #292773
	# and additional scripts from tools dir
	if use tools; then
		local app
		local apps="${PN}-editor pydict2dic olddic2newdic oxford2dic directory2dic dictd2dic
			wquick2dic ec50 directory2treedic treedict2dir jdictionary mova xmlinout
			soothill kanjidic2 powerword kdic 21tech 21shiji buddhist tabfile
			cedict edict duden ${PN}-dict-update degb2utf frgb2utf jpgb2utf gmx2utf
			rucn kingsoft kingsoft2 wikipedia wikipediaImage babylon ${PN}2txt ${PN}-verify
			fest2dict i2e2dict downloadwiki ooo2dict myspell2dic exc2i2e
			dictbuilder tabfile2sql KangXi Unihan xiaoxuetang-ja wubi ydp2dict
			wordnet lingvosound2resdb resdatabase2dir dir2resdatabase ${PN}-index
			sd2foldoc
			${PN}-text2bin ${PN}-bin2text ${PN}-repair"

		use perl && apps+=" dicts-dump.pl ncce2stardict.pl parse-oxford.perl"

		for app in ${apps}; do
			if [[ "${app}" =~ ^${PN} ]]; then
				dobin "tools/src/${app}"
			else
				newbin "tools/src/${app}" "${PN}_${app}"
			fi
		done

		docinto tools
		dodoc tools/{AUTHORS,ChangeLog,README}

		if use examples; then
			docinto tools
			dodoc tools/src/{dictbuilder.{example,readme},example.ifo,example_treedict.tar.bz2}
			docompress -x /usr/share/doc/${PF}/tools
		fi
	fi
}

pkg_postinst() {
	elog
	elog "Note: festival text to speech (TTS) plugin is not built. To use festival"
	elog 'TTS plugin, please, emerge festival and enable "Use TTS program." at:'
	elog '"Preferences -> Dictionary -> Sound" and fill in "Commandline" with:'
	elog '"echo %s | festival --tts"'
	elog
	elog "You will now need to install ${PN} dictionary files. If"
	elog "you have not, execute the below to get a list of dictionaries:"
	elog "  emerge -s ${PN}-"
	elog
	elog "Additionally you may install any stardict dictionary from the net"
	elog "by unpacking it to:"
	elog "  /usr/share/stardict/dic"
	elog

	gnome2_pkg_postinst
}
