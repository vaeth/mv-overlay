# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
FROM_LANG="German"
TO_LANG="Italian"
DICT_PREFIX="dictd_www.freedict.de_"
inherit stardict
RESTRICT="mirror"

HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_dictd-www.freedict.de.php"
KEYWORDS="~amd64 ~x86"
IUSE=""
