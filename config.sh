# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

ARCHIVE_SDIR=pillow-depends-master

# Package versions for fresh source builds
FREETYPE_VERSION=2.9.1
LIBPNG_VERSION=1.6.35
ZLIB_VERSION=1.2.11
JPEG_VERSION=9c
OPENJPEG_VERSION=2.1
XZ_VERSION=5.2.4
TIFF_VERSION=4.0.9
LCMS2_VERSION=2.9
GIFLIB_VERSION=5.1.4
LIBWEBP_VERSION=1.0.0

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    curl -fsSL -o pillow-depends-master.zip https://github.com/python-pillow/pillow-depends/archive/master.zip
    untar pillow-depends-master.zip
    if [ -n "$IS_OSX" ]; then
        # Update to latest zlib for OSX build
        build_new_zlib
    fi
    build_jpeg
    build_tiff
    build_libpng
    build_openjpeg
    if [ -n "$IS_OSX" ]; then
        # Fix openjpeg library install id
        # https://code.google.com/p/openjpeg/issues/detail?id=367
        install_name_tool -id $BUILD_PREFIX/lib/libopenjp2.7.dylib $BUILD_PREFIX/lib/libopenjp2.2.1.0.dylib
    fi
    build_lcms2
    build_libwebp
    if [ -n "$IS_OSX" ]; then
        # Custom freetype build
        build_simple freetype $FREETYPE_VERSION https://download.savannah.gnu.org/releases/freetype tar.gz --with-harfbuzz=no
    else
        build_freetype
    fi
}

EXP_CODECS="jpg jpg_2000 libtiff zlib"
EXP_MODULES="freetype2 littlecms2 pil tkinter webp"