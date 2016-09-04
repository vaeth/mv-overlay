# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="A GTK+ frontend for espeak"
HOMEPAGE="http://www.muflone.com/gespeaker/english/index.html"
EGIT_COMMIT="3936e33cf3ec5523a0466950d93261fb82987d0f"
SRC_URI="https://github.com/muflone/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
KEYWORDS=""

IUSE="linguas_ar linguas_bg linguas_de linguas_en linguas_es linguas_fo linguas_fr linguas_it linguas_pl linguas_tr linguas_vi"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="app-accessibility/espeak
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	gnome-base/librsvg
	${PYTHON_DEPS}"

src_prepare() {
	distutils-r1_python_prepare_all
	python_setup 'python2*'
	python_fix_shebang "${S}"
	sed -i \
		-e 's!share/doc/gespeaker/dbus!share/gtk-doc/gspeaker!' \
		-e "s!share/doc/gespeaker!share/doc/${PF}!" \
		-- "${S}/setup.py" || die
	eapply_user
}
