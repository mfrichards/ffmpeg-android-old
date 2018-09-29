#!/bin/bash

NDK=~/android/android-ndk-r6b
SYSROOT=$NDK/platforms/android-9/arch-arm
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/linux-x86
export PATH=$TOOLCHAIN/bin:$PATH
echo $PATH

rm -rf build/ffmpeg
mkdir -p build/ffmpeg
cd ffmpeg

LDFLAGS=""

# Don't build any neon version for now
for version in armv5te armv7a; do

	DEST=../build/ffmpeg
	FLAGS="--target-os=linux"
	FLAGS="$FLAGS --sysroot=$SYSROOT"
	FLAGS="$FLAGS --arch=arm"
	FLAGS="$FLAGS --enable-cross-compile"
	FLAGS="$FLAGS --cross-prefix=arm-linux-androideabi-"
	FLAGS="$FLAGS --enable-shared"
	FLAGS="$FLAGS --disable-symver"
	FLAGS="$FLAGS --enable-small"
	FLAGS="$FLAGS --enable-pic"
	FLAGS="$FLAGS --disable-dxva2"
	FLAGS="$FLAGS --disable-avdevice"
	FLAGS="$FLAGS --disable-swscale"
	FLAGS="$FLAGS --disable-avfilter"
	FLAGS="$FLAGS --disable-network"
	FLAGS="$FLAGS --disable-ffmpeg"
	FLAGS="$FLAGS --disable-ffplay"
	FLAGS="$FLAGS --disable-ffprobe"
	FLAGS="$FLAGS --disable-ffserver"
	FLAGS="$FLAGS --disable-everything"
	FLAGS="$FLAGS --enable-decoder=mp2"
	FLAGS="$FLAGS --enable-decoder=mp3"
	FLAGS="$FLAGS --enable-decoder=alac"
	FLAGS="$FLAGS --enable-decoder=pcm_s16be"
	FLAGS="$FLAGS --enable-decoder=pcm_s16le"
	FLAGS="$FLAGS --enable-decoder=pcm_u16be"
	FLAGS="$FLAGS --enable-decoder=pcm_u16le"
	FLAGS="$FLAGS --enable-decoder=pcm_alaw"
	FLAGS="$FLAGS --enable-decoder=pcm_mulaw"
	FLAGS="$FLAGS --enable-decoder=pcm_s16le_planar"
	FLAGS="$FLAGS --enable-decoder=adpcm_ms"
	FLAGS="$FLAGS --enable-decoder=adpcm_g726"
	FLAGS="$FLAGS --enable-decoder=gsm"
	FLAGS="$FLAGS --enable-decoder=gsm_ms"
	FLAGS="$FLAGS --enable-decoder=tta"
	FLAGS="$FLAGS --enable-decoder=wmapro"
	FLAGS="$FLAGS --enable-decoder=ape"
	FLAGS="$FLAGS --enable-parser=mpegaudio"
	FLAGS="$FLAGS --enable-protocol=file"
	FLAGS="$FLAGS --enable-protocol=pipe"
	FLAGS="$FLAGS --enable-demuxer=mp3"
	FLAGS="$FLAGS --enable-demuxer=mov"
	FLAGS="$FLAGS --enable-demuxer=asf"
	FLAGS="$FLAGS --enable-demuxer=pcm_s16be"
	FLAGS="$FLAGS --enable-demuxer=pcm_s16le"
	FLAGS="$FLAGS --enable-demuxer=pcm_u16be"
	FLAGS="$FLAGS --enable-demuxer=pcm_u16le"
	FLAGS="$FLAGS --enable-demuxer=pcm_alaw"
	FLAGS="$FLAGS --enable-demuxer=pcm_mulaw"
	FLAGS="$FLAGS --enable-demuxer=tta"
	FLAGS="$FLAGS --enable-demuxer=wav"
	FLAGS="$FLAGS --enable-demuxer=aiff"
	FLAGS="$FLAGS --enable-demuxer=ape"
	FLAGS="$FLAGS --enable-decoder=aac"
	FLAGS="$FLAGS --enable-parser=aac"
	FLAGS="$FLAGS --enable-demuxer=aac"
	FLAGS="$FLAGS --enable-decoder=vorbis"
	FLAGS="$FLAGS --enable-demuxer=ogg"
	FLAGS="$FLAGS --enable-decoder=flac"
	FLAGS="$FLAGS --enable-parser=flac"
	FLAGS="$FLAGS --enable-demuxer=flac"

	case "$version" in
		neon)
			EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
			EXTRA_LDFLAGS=" -Wl,--fix-cortex-a8"
			XFLAGS="--enable-decoder=wmav1"
			XFLAGS="$XFLAGS --enable-decoder=wmav2"
			ABI="armeabi-v7a"
			;;
		armv7a)
			EXTRA_CFLAGS="-march=armv7-a -mfloat-abi=softfp"
			EXTRA_LDFLAGS=""
			XFLAGS="--enable-decoder=wmav1"
			XFLAGS="$XFLAGS --enable-decoder=wmav2"
			ABI="armeabi-v7a"
			;;
		*)
			EXTRA_CFLAGS=""
			EXTRA_LDFLAGS=""
			XFLAGS="--enable-decoder=wmav1"
			XFLAGS="$XFLAGS --enable-decoder=wmav2"
			ABI="armeabi"
			;;
	esac
	DEST="$DEST/$ABI"
	FLAGS="$FLAGS --prefix=$DEST"

	mkdir -p $DEST
	echo $FLAGS $XFLAGS --extra-cflags="\"$EXTRA_CFLAGS\"" --extra-ldflags="\"$LDFLAGS$EXTRA_LDFLAGS\"" > $DEST/info.txt
	./configure $FLAGS $XFLAGS --extra-cflags="\"$EXTRA_CFLAGS\"" --extra-ldflags="\"$LDFLAGS$EXTRA_LDFLAGS\"" | tee $DEST/configuration.txt
	[ $PIPESTATUS == 0 ] || exit 1
	make clean
	make -j4 || exit 1
	make install || exit 1

done

