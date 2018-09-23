# Copyright 2015-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
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
KEYWORDS=""
PLOCALES="ar bg de en es fo fr it pl tr vi"
IUSE=
for i in ${PLOCALES}; do
	IUSE+=${IUSE:+\ }"l10n_${i}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="app-accessibility/espeak
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	gnome-base/librsvg
	${PYTHON_DEPS}"

src_prepare() {
	local i
	export LINGUAS=
	for i in ${PLOCALES}; do
		use l10n_${i} && LINGUAS+=${LINGUAS:+ }${i}
	done
	distutils-r1_python_prepare_all
	python_setup 'python2*'
	python_fix_shebang "${S}"
	sed -i \
		-e 's!share/doc/gespeaker/dbus!share/gtk-doc/gspeaker!' \
		-e "s!share/doc/gespeaker!share/doc/${PF}!" \
		-- "${S}/setup.py" || die
	default
}
