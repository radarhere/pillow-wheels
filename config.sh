# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

ARCHIVE_SDIR=pillow-depends-master

# Package versions for fresh source builds
FREETYPE_VERSION=2.10.4
LIBPNG_VERSION=1.6.37
ZLIB_VERSION=1.2.11
JPEG_VERSION=9d
OPENJPEG_VERSION=2.4.0
XZ_VERSION=5.2.5
TIFF_VERSION=4.2.0
LCMS2_VERSION=2.11
GIFLIB_VERSION=5.1.4
LIBWEBP_VERSION=1.1.0
BZIP2_VERSION=1.0.8
LIBXCB_VERSION=1.14

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    curl -fsSL -o pillow-depends-master.zip https://github.com/python-pillow/pillow-depends/archive/master.zip
    untar pillow-depends-master.zip
    if [ -n "$IS_MACOS" ]; then
        # Update to latest zlib for macOS build
        build_new_zlib
    fi
    
    # Custom flags to include both multibuild and jpeg defaults
    ORIGINAL_CFLAGS=$CFLAGS
    CFLAGS="$CFLAGS -g -O2"
    build_jpeg
    CFLAGS=$ORIGINAL_CFLAGS

    build_tiff
    build_libpng
    build_lcms2

    if [ -n "$IS_MACOS" ]; then
        # Custom freetype build
        build_simple freetype $FREETYPE_VERSION https://download.savannah.gnu.org/releases/freetype tar.gz --with-harfbuzz=no --with-brotli=no
    else
        build_freetype
    fi

    # Append licenses
    for filename in dependency_licenses/*; do
      echo -e "\n\n----\n\n$(basename $filename | cut -f 1 -d '.')\n" | cat >> Pillow/LICENSE
      cat $filename >> Pillow/LICENSE
    done
}

function run_tests_in_repo {
    # Run Pillow tests from within source repo
    python3 selftest.py
    pytest
}

EXP_CODECS="jpg"
EXP_CODECS="$EXP_CODECS libtiff zlib"
EXP_MODULES="freetype2 littlecms2 pil tkinter"
EXP_FEATURES="transp_webp webp_anim webp_mux"

function run_tests {
    local ret=0
    if [[ "$MB_PYTHON_VERSION" == pypy3.7-* ]] && [[ $(uname -m) == "i686" ]]; then
        python3 -m pip install numpy --disable-optimization
    else
        python3 -m pip install numpy
    fi
    return $ret
}
