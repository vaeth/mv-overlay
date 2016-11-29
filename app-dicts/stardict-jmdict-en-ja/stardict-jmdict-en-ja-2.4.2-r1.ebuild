# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
FROM_LANG="English"
TO_LANG="Japanese"
DICT_PREFIX="jmdict-"
DESCRIPTION=""
inherit stardict
HOMEPAGE="http://download.huzheng.org/ja/"
SRC_URI="http://download.huzheng.org/ja/${P}.tar.bz2"
LICENSE="GDLS"
KEYWORDS="amd64 ~arm64 x86"
IUSE=""
