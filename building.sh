#!/bin/bash

LANG=C
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

# Location of "toolchains" folder
export RDIR=$PWD
export TOOL_DIR=($RDIR/../ToolDragon9)
export KERNEL_NAME=aLn-Kernel
export KERNEL_VERSION=vA1
export KERNEL_DEFCONFIG=vince_defconfig
export KBUILD_BUILD_USER=alanndz
export KBUILD_BUILD_HOST=Ubuntu_18.04

export KSCHED=HMP
export TWEAKER=ST
export ARCH=arm64
export BUILD_CROSS_COMPILE=$TOOL_DIR/linaro8/bin/aarch64-opt-linux-android-
export TS=TOOLSET/
export CORES=`grep processor /proc/cpuinfo|wc -l`
export GIT_LOG1=`git log --oneline --decorate -n 1`
export DATE=$(date +"[%Y-%m-%d]");

export OUT_DIR=$RDIR/../Out
export KERN_IMG=$RDIR/../Out/arch/arm64/boot/Image.gz-dtb
export ZIP_DIR=$TOOL_DIR/AnyKernel2

#telegram function
TELE_TOKEN=799058967:AAHdBKLP8cjxLXUCxeBiWmEOoY8kZHvbiQo
TELE_ID=671339354
function sendInfo() {
	curl -d "parse_mode=HTML" -d text="${1}" -d chat_id="$TELE_ID" -d "disable_web_page_preview=true" -s "https://api.telegram.org/bot$TELE_TOKEN/sendMessage"
}

echo -e "${blink_red}"
echo "starting build of $TARGET - $COMPILER"
echo -e "${restore}"

KBUILD_LOUP_CFLAGS="-Wno-unknown-warning-option -Wno-sometimes-uninitialized -Wno-vectorizer-no-neon -Wno-pointer-sign -Wno-sometimes-uninitialized -Wno-tautological-constant-out-of-range-compare -Wno-literal-conversion -Wno-enum-conversion -Wno-parentheses-equality -Wno-typedef-redefinition -Wno-constant-logical-operand -Wno-array-bounds -Wno-empty-body -Wno-non-literal-null-conversion -Wno-shift-overflow -Wno-logical-not-parentheses -Wno-strlcpy-strlcat-size -Wno-section -Wno-stringop-truncation -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2"


make ARCH=$ARCH mrproper;
make O=$OUTDIR clean;

# sed -i 's/=m/=y/g' arch/$ARCH/configs/$KERNEL_DEFCONFIG

FUNC_DTC_COMM()
{
export CC=$TOOL_DIR/Clang/bin/clang
export CLANG_TRIPLE=aarch64-opt-linux-android-
export CLANG_LD_PATH=$TOOL_DIR/Clang/lib64
export LLVM_DIS=$TOOL_DIR/Clang/bin/llvm-dis
}

echo "build config: "$KERNEL_DEFCONFIG ""
echo "git info: "$GIT_LOG1 ""
if [ $CLANG -eq "1" ];then
	echo "compiling with clang"
else
	echo "compiling with gcc"
fi;

	echo -e "\ncleaning..."
	FUNC_CLEAN_DTB | grep :

	echo "generating .config"
	make -j$CORES O=$OUT_DIR ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG | grep :

	echo "compiling..."

if [ $CLANG -eq "1" ];then
	LD_LIBRARY_PATH="$CLANG_LD_PATH:$LD_LIBARY_PATH" \
	make -j$CORES O=$OUT_DIR LOCALVERSION="-$KERNEL_VERSION" ARCH=$ARCH \
			CROSS_COMPILE="$BUILD_CROSS_COMPILE" \
			CC="ccache $CC" CLANG_TRIPLE="$CLANG_TRIPLE" \
			KBUILD_COMPILER_STRING="$CLANG_VERSION" \
			LLVM_DIS="$LLVM_DIS" \
			KBUILD_LOUP_CFLAGS="$KBUILD_LOUP_CFLAGS" \
			KCFLAGS="-mllvm -polly \
					-mllvm -polly-run-dce \
					-mllvm -polly-run-inliner \
					-mllvm -polly-opt-fusion=max \
					-mllvm -polly-ast-use-context \
					-mllvm -polly-vectorizer=stripmine \
					-mllvm -polly-detect-keep-going" | grep :
else
	make -j$CORES O=$OUT_DIR LOCALVERSION="-$KERNEL_VERSION" ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			CC='ccache '${BUILD_CROSS_COMPILE}gcc \
			KBUILD_LOUP_CFLAGS="$KBUILD_LOUP_CFLAGS" | grep :
fi;

if [ ! -f $KERN_IMG ]; then
	echo -e "${red}"
	echo -e "Kernel STUCK in BUILD! no Image exist !"
	echo -e "${restore}"
	exit 1
fi;
}


    FILE=$RDIR/include/generated/compile.h
    export "$(grep "${1}" "${FILE}" | cut -d'"' -f1 | awk '{print $2}')"="$(grep "${1}" "${FILE}" | cut -d'"' -f2)"

    evv UTS_VERSION
    evv LINUX_COMPILE_BY
    evv LINUX_COMPILE_HOST
    evv LINUX_COMPILER
    VERSION=$(cat $RDIR/include/config/kernel.release)
    echo "Linux version ${VERSION} (${LINUX_COMPILE_BY}@${LINUX_COMPILE_HOST}) (${LINUX_COMPILER}) ${UTS_VERSION}"


sendInfo "$(echo -e"Linux version ${VERSION} (${LINUX_COMPILE_BY}@${LINUX_COMPILE_HOST}) (${LINUX_COMPILER}) ${UTS_VERSION}")"

# ZIPING
cd $ZIP_DIR
make clean &>/dev/null
cp $KERN_IMG $ZIP_DIR/zImage
make NAME=$KERNEL_NAME CODE=$KERNEL_VERSION normal &>/dev/null
make NAME=$KERNEL_NAME CODE=$KERNEL_VERSION TELE_TOKEN=$TELE_TOKEN TELE_ID=$TELE_ID sendtele&>/dev/null 

cd $RDIR
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
#end of all build process