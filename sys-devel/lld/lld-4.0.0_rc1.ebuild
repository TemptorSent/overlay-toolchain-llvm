# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
# (needed due to CMAKE_BUILD_TYPE != Gentoo)
CMAKE_MIN_VERSION=3.7.0-r1
PYTHON_COMPAT=( python2_7 )

inherit cmake-utils git-r3

DESCRIPTION="The LLVM linker (link editor)"
HOMEPAGE="http://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="http://llvm.org/git/lld.git
	https://github.com/llvm-mirror/lld.git"
EGIT_BRANCH="release_40"
EGIT_COMMIT="83a83a52d143ff3d21ab86fbc884fb2caa211cbc"

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS=""
IUSE="test"

RDEPEND="~sys-devel/llvm-${PV}"
DEPEND="${RDEPEND}
	test? ( ~dev-python/lit-${PV} )"

# TODO: fix test suite to build stand-alone
RESTRICT="test"

# least intrusive of all
CMAKE_BUILD_TYPE=RelWithDebInfo

src_unpack() {
	if use test; then
		# needed for patched gtest
		git-r3_fetch "http://llvm.org/git/llvm.git
			https://github.com/llvm-mirror/llvm.git" \
			c329efbc3c94928fb826ed146897aada0459c983
	fi
	git-r3_fetch

	if use test; then
		git-r3_checkout http://llvm.org/git/llvm.git \
			"${WORKDIR}"/llvm
	fi
	git-r3_checkout
}

src_configure() {
	local libdir=$(get_libdir)
	local mycmakeargs=(
		# TODO: fix rpaths
		#-DBUILD_SHARED_LIBS=ON

		-DLLVM_INCLUDE_TESTS=$(usex test)
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	use test && mycmakeargs+=(
		-DLLVM_MAIN_SRC_DIR="${WORKDIR}/llvm"
		-DLIT_COMMAND="${EPREFIX}/usr/bin/lit"
	)

	cmake-utils_src_configure
}

src_test() {
	cmake-utils_src_make check-lld
}
