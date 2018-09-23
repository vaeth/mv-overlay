# Copyright 2015-2018 Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="mirror"
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="A GTK+ frontend for espeak"
HOMEPAGE="http://www.muflone.com/gespeaker/english/index.html"
SRC_URI="https://github.com/muflone/gespeaker/releases/download/${PV}/${P}.tar.gz
	http://www.muflone.com/resources/gespeaker/archive/${PV}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x64-cygwin ~x86-fbsd"
PLOCALES="ar bg de en es fo fr it pl tr vi"
IUSE=
for i in ${PLOCALES}; do
	IUSE+=${IUSE:+\ }"l10n_${i}"
done

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="app-accessibility/espeak
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygtk[${PYTHON_USEDEP}]
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
	use prefix || sed -i \
			-e '1s"^#!/usr/bin/env python$"#!'"${EPREFIX}/usr/bin/python"'"' \
			-- "${S}/setup.py" "${S}/src/gespeaker.py" || die
	python_setup 'python2*'
	python_fix_shebang "${S}"
	sed -i \
		-e 's!share/doc/gespeaker/dbus!share/gtk-doc/gspeaker!' \
		-e "s!share/doc/gespeaker!share/doc/${PF}!" \
		-- "${S}/setup.py" || die
	sed -i \
		-e 's!env python gespeaker\.py!./gespeaker.py!' \
		-- "${S}/gespeaker" || die
	default
}
