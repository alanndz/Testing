#!/usr/bin/env bash

# Source Code from https://gist.github.com/VRanger/dd2da6956fe1acd9d52d8c4d4dfc48e9

export KERNELDIR=$PWD
export TOOLDIR=$KERNELDIR/../ToolDragon9
export CONFIG_FILE="vince_defconfig"
export ARCH=arm64
export SUBARCH=arm64

export KERNEL_NAME="aLn"
export KERNEL_VERSION="vA2"

export KBUILD_BUILD_USER="alanndz"
export KBUILD_BUILD_HOST="n00b"

export ARM64GCC="${TOOLDIR}/linaro8/bin/aarch64-linux-gnu-"
# export ARM64GCC="$HOME/gcc/bin/aarch64-opt-linux-android-"
export CLANG_TCHAIN="${TOOLDIR}/Clang/bin/clang"
export CLANG_LD_PATH="${TOOLDIR}/Clang/lib64"
export LLVM_DIS="${TOOLDIR}/Clang/bin/llvm-dis"
KBUILD_LOUP_CFLAGS="-Wno-unknown-warning-option -Wno-sometimes-uninitialized -Wno-vectorizer-no-neon -Wno-pointer-sign -Wno-sometimes-uninitialized -Wno-tautological-constant-out-of-range-compare -Wno-literal-conversion -Wno-enum-conversion -Wno-parentheses-equality -Wno-typedef-redefinition -Wno-constant-logical-operand -Wno-array-bounds -Wno-empty-body -Wno-non-literal-null-conversion -Wno-shift-overflow -Wno-logical-not-parentheses -Wno-strlcpy-strlcat-size -Wno-section -Wno-stringop-truncation -mtune=cortex-a53 -march=armv8-a+crc+simd+crypto -mcpu=cortex-a53 -O2"

export OUTDIR="${KERNELDIR}/../Output"
# export builddir="${KERNELDIR}/../Builds"

# export DTBTOOL="${KERNELDIR}/Dtbtool"
export ANY_KERNEL2_DIR="${TOOLDIR}/AnyKernel2"
export ZIP_NAME="${KERNEL_NAME}-${KERNEL_VERSION}-Clang_$(git rev-parse --abbrev-ref HEAD).zip"
export IMAGE="${OUTDIR}/arch/arm64/boot/Image.gz-dtb";

export BOT_API_KEY=799058967:AAHdBKLP8cjxLXUCxeBiWmEOoY8kZHvbiQo
export CHAT_ID=@671339354

CLANG_VERSION=$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
JOBS="-j$(($(nproc --all) + 1))"
cd $KERNELDIR

make_a_fucking_defconfig() {
	make O=${OUTDIR} $CONFIG_FILE
}

clean_outdir() {
    make O=${OUTDIR} clean
    make mrproper
}

compile() {
	LD_LIBRARY_PATH="${CLANG_LD_PATH}:${LD_LIBARY_PATH}"  make \
		O="${OUTDIR}" \
		LOCALVERSION="-${KERNEL_VERSION}"
		CC="ccache ${CLANG_TCHAIN}" \
		CROSS_COMPILE="${ARM64GCC}" \
		HOSTCC="${CLANG_TCHAIN}" \
		KBUILD_COMPILER_STRING="${CLANG_VERSION}" \
		"${JOBS}"
}

compilee() {
	LD_LIBRARY_PATH="$CLANG_LD_PATH:$LD_LIBARY_PATH" \
	make "${JOBS}" ARCH=$ARCH \
			CROSS_COMPILE="${ARM64GCC}" \
			CC="ccache ${CLANG_TCHAIN}" \
			KBUILD_COMPILER_STRING="${CLANG_VERSION}" \
			LLVM_DIS="$LLVM_DIS" \
			KBUILD_LOUP_CFLAGS="$KBUILD_LOUP_CFLAGS" \
			KCFLAGS="-mllvm -polly \
					-mllvm -polly-run-dce \
					-mllvm -polly-run-inliner \
					-mllvm -polly-opt-fusion=max \
					-mllvm -polly-ast-use-context \
					-mllvm -polly-vectorizer=stripmine \
					-mllvm -polly-detect-keep-going"
}

zipit () {
	if [[ ! -f "${IMAGE}" ]]; then
        	echo -e "Build failed :P";
        	exit 1;
   	else
        	echo -e "Build Succesful!";
    	fi
    	echo "**** Copying zImage ****"
    	cd ${ANY_KERNEL2_DIR}/
        make clean &>/dev/null
        cp ${IMAGE} ${ANY_KERNEL2_DIR}/zImage
        make ZIP=${ZIP_NAME} normal &>/dev/null
        make ZIP=${ZIP_NAME} TELE_TOKEN=$BOT_API_KEY TELE_ID=$CHAT_ID sendtele
}

deploy() {

curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="Informations:" -d chat_id=$CHAT_ID
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="Device: Vince" -d chat_id=$CHAT_ID
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="Branch: $(git rev-parse --abbrev-ref HEAD)" -d chat_id=$CHAT_ID
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="Commit: $(git log --pretty=format:'%h : %s' -1)" -d chat_id=$CHAT_ID
curl -s -X POST https://api.telegram.org/bot$BOT_API_KEY/sendMessage -d text="Download:" -d chat_id=$CHAT_ID
# curl -F chat_id="$CHAT_ID" -F document=@"$PWD/$ZIP_NAME" https://api.telegram.org/bot$BOT_API_KEY/sendDocument
}

clean_outdir
make_a_fucking_defconfig
#compile
compilee
deploy
zipit
