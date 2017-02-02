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
--enable-libx265
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

# x265
cd $BUILD/custom_majcn
hg clone https://bitbucket.org/multicoreware/x265
cd x265
# https://bitbucket.org/multicoreware/x265/issues/289
sed -i .bak 's/set(ARM_ARGS -mcpu=native -mfloat-abi=hard -mfpu=neon -marm -fPIC)/set(ARM_ARGS -mcpu=cortex-a53 -mfloat-abi=hard -mfpu=neon-vfpv4 -marm -fPIC)/' source/CMakeLists.txt 
cd build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$BUILD/build_libs" -DENABLE_SHARED:bool=off ../../source
make
make install

# fdkaac
cd $BUILD/custom_majcn
wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master
tar xzvf fdk-aac.tar.gz
cd mstorsjo-fdk-aac*
./autogen.sh --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
./configure  --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
make
make install

# opus
cd $BUILD/custom_majcn
wget http://downloads.xiph.org/releases/opus/opus-1.1.4.tar.gz
tar xzvf opus-1.1.4.tar.gz
cd opus-1.1.4
./autogen.sh --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
./configure  --prefix="$BUILD/build_libs" --libdir="$BUILD/build_libs/lib" --enable-static --disable-shared $OPTIONS
make
make install
