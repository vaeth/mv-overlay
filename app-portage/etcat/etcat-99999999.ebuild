# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( pypy python2_7 python3_3 python3_4 python3_5 )
EGIT_REPO_URI="git://github.com/proteusx/${PN}.git"
inherit git-r3 python-single-r1

DESCRIPTION="Updated version of an old Portage information extractor"
HOMEPAGE="https://github.com/proteusx/etcat/"
SRC_URI=""
PROPERTIES="live"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="app-portage/gentoolkit[${PYTHON_USEDEP}]"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	sed -i -e 's/        /	/g' \
		-e 's/^\(.*[ 	]\)\?print \(.*\)$/\1print(\2)/' \
		-e 's/^\(.*[ 	]\)\?\(except .*\), \(.*\)$/\1\2 as \3/' \
		-- "${S}/${PN}"
	python_fix_shebang --force "${S}"
	eapply_user
}

src_install() {
	dobin "${PN}"
}
