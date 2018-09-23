# Copyright 1999-2018 Gentoo Authors and Martin V\"ath
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A virtual to choose between different icon themes"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~mips ppc ppc64 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x86-solaris"
SRC_URI=""
LICENSE=""
HOMEPAGE=""
IUSE=""

# Compared to the gentoo repository, we add:
# hicolor-icon-theme (which is needed for gimp anyway)

RDEPEND="|| (
	x11-themes/hicolor-icon-theme
	lxde-base/lxde-icon-theme
	x11-themes/tango-icon-theme
	kde-frameworks/oxygen-icons
	x11-themes/mate-icon-theme
	x11-themes/elementary-xfce-icon-theme
	x11-themes/adwaita-icon-theme
	x11-themes/faenza-icon-theme
)
"
