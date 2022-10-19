# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit savedconfig toolchain-funcs

DESCRIPTION="Desktop Environment built around Suckless Utilities"
HOMEPAGE="https://github.com/toasterbirb/dde/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/toasterbirb/dde"
else
	SRC_URI="https://github.com/toasterbirb/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~x86"	
fi

LICENSE="MIT"
SLOT="0"
IUSE="xinerama"

RDEPEND="
	media-libs/fontconfig
	x11-libs/libX11
	>=x11-libs/libXft-2.3.5
	xinerama? ( x11-libs/libXinerama )
"

DEPEND="
	${RDEPEND}
	xinerama? ( x11-base/xorg-proto )
"

src_prepare() {
	default

	sed -i \
		-e "s/ -Os / /" \
		-e "/^\(LDFLAGS\|CFLAGS\|CPPFLAGS\)/{s| = | += |g;s|-s ||g}" \
		-e "/^X11LIB/{s:/usr/X11R6/lib:/usr/$(get_libdir)/X11:}" \
		-e '/^X11INC/{s:/usr/X11R6/include:/usr/include/X11:}' \
		dwm/config.mk || die

	restore_config dwm/config.h
}

src_compile() {
	if use xinerama; then
		emake -C dwm CC="$(tc-getCC)" dwm
	else
		emake -C dwm CC="$(tc-getCC)" XINERAMAFLAGS="" XINERAMALIBS="" dwm
	fi
}

src_install() {
	emake -C dwm DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install

	dodoc dwm/README

	save_config dwm/config.h
}
