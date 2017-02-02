#!/bin/sh
set -e
BUILD="$(pwd)"

# ffmpeg options
cat <<EOT > $BUILD/ffmpeg_options
--enable-mmal
--enable-pic
--enable-gpl
--enable-libass
--enable-libfdk-aac
--enable-libfreetype
--enable-libmp3lame
--enable-libopus
--enable-libtheora
--enable-libvorbis
--enable-libvpx
--enable-libx264
--enable-nonfree
--enable-gnutls
--disable-debug
--disable-doc
EOT



OPTIONS="$@"

case "$PKG_CONFIG_PATH" in
  '')
    export PKG_CONFIG_PATH="$BUILD/build_libs/lib/pkgconfig"
    ;;
  *)
    export PKG_CONFIG_PATH="$BUILD/build_libs/lib/pkgconfig:$PKG_CONFIG_PATH"
    ;;
esac

rm -rf custom_majcn
mkdir custom_majcn

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

# x264
cd $BUILD/custom_majcn
wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjvf last_x264.tar.bz2
cd x264-snapshot*
./configure --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
make
make install

# fdkaac
cd $BUILD/custom_majcn
git clone https://github.com/mstorsjo/fdk-aac
cd fdk-aac
./autogen.sh --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
./configure  --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
make
make install

# opus
cd $BUILD/custom_majcn
git clone https://github.com/xiph/opus
cd opus
./autogen.sh --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
./configure  --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
make
make install
