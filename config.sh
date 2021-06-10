# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

ARCHIVE_SDIR=pillow-depends-master

# Package versions for fresh source builds
FREETYPE_VERSION=2.10.4
HARFBUZZ_VERSION=2.8.1
LIBPNG_VERSION=1.6.37
ZLIB_VERSION=1.2.11
JPEG_VERSION=9d
OPENJPEG_VERSION=2.4.0
XZ_VERSION=5.2.5
TIFF_VERSION=4.3.0
LCMS2_VERSION=2.12
GIFLIB_VERSION=5.1.4
LIBWEBP_VERSION=1.2.0
BZIP2_VERSION=1.0.8
LIBXCB_VERSION=1.14

# workaround for multibuild bug with .tar.xz
function untar {
    local in_fname=$1
    if [ -z "$in_fname" ];then echo "in_fname not defined"; exit 1; fi
    local extension=${in_fname##*.}
    case $extension in
        tar) tar -xf $in_fname ;;
        gz|tgz) tar -zxf $in_fname ;;
        bz2) tar -jxf $in_fname ;;
        zip) unzip -qq $in_fname ;;
        xz) if [ -n "$IS_MACOS" ]; then
              tar -xf $in_fname
            else
              if [[ ! $(type -P "unxz") ]]; then
                echo xz must be installed to uncompress file; exit 1
              fi
              unxz -c $in_fname | tar -xf -
            fi ;;
        *) echo Did not recognize extension $extension; exit 1 ;;
    esac
}

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

    # Append licenses
    for filename in dependency_licenses/*; do
      echo -e "\n\n----\n\n$(basename $filename | cut -f 1 -d '.')\n" | cat >> Pillow/LICENSE
      cat $filename >> Pillow/LICENSE
    done
}

function pip_wheel_cmd {
    local abs_wheelhouse=$1
    if [ -z "$IS_MACOS" ]; then
        CFLAGS="$CFLAGS --std=c99"  # for Raqm
    fi
    pip wheel $(pip_opts) \
        --global-option build_ext \
        -w $abs_wheelhouse --no-deps .
}

function run_tests_in_repo {
    # Run Pillow tests from within source repo
    python3 selftest.py
    pytest
}

EXP_CODECS="jpg jpg_2000"
EXP_CODECS="$EXP_CODECS libtiff zlib"
EXP_MODULES="freetype2 littlecms2 pil tkinter webp"
if [ -z "$IS_MACOS" ] && [[ "$MB_PYTHON_VERSION" != pypy3* ]] && [[ "$MACHTYPE" != aarch64* ]]; then
  EXP_FEATURES="fribidi harfbuzz raqm transp_webp webp_anim webp_mux xcb"
else
  # can't find FriBiDi
  EXP_FEATURES="transp_webp webp_anim webp_mux xcb"
fi

function run_tests {
    if [ -n "$IS_MACOS" ]; then
        brew install openblas
        echo -e "[openblas]\nlibraries = openblas\nlibrary_dirs = /usr/local/opt/openblas/lib" >> ~/.numpy-site.cfg
    fi
    if [[ "$MB_PYTHON_VERSION" == pypy3.7-* ]] && [[ $(uname -m) == "i686" ]]; then
        python3 -m pip install numpy==1.19.5
    else
        python3 -m pip install numpy
    fi

    mv ../pillow-depends-master/test_images/* ../Pillow/Tests/images

    # Runs tests on installed distribution from an empty directory
    (cd ../Pillow && run_tests_in_repo)
    # Test against expected codecs, modules and features
    local ret=0
    return $ret
}
