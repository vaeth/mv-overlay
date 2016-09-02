# Copyright 2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A virtual to choose between different icon themes"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE=""

# Compared to the gentoo repository, we add:
# hicolor-icon-theme (which is needed for gimp anyway)
# adwaita-icon-theme

RDEPEND="|| (
	x11-themes/hicolor-icon-theme
	lxde-base/lxde-icon-theme
	x11-themes/tango-icon-theme
	kde-frameworks/oxygen-icons
	x11-themes/mate-icon-theme
	x11-themes/adwaita-icon-theme
	x11-themes/gnome-icon-theme
	x11-themes/faenza-icon-theme
)
"
