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
export CLANG_LD_PATH="${CLANG_TCHAIN}/lib64"

export OUTDIR="${KERNELDIR}/../Output"
export builddir="${KERNELDIR}/../Builds"

# export DTBTOOL="${KERNELDIR}/Dtbtool"
export ANY_KERNEL2_DIR="${TOOLDIR}/AnyKernel2"
export ZIP_NAME="${KERNEL_NAME}-${KERNEL_VERSION}-Clang_$(git rev-parse --abbrev-ref HEAD).zip"
export IMAGE="${OUTDIR}/arch/arm64/boot/Image.gz-dtb";

export BOT_API_KEY=799058967:AAHdBKLP8cjxLXUCxeBiWmEOoY8kZHvbiQo
export CHAT_ID=@aLnKernel

CLANG_VERSION=$(${CLANG_TCHAIN} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
JOBS="-j$(($(nproc --all) + 1))"
cd $KERNELDIR

make_a_fucking_defconfig() {
	make O=${OUTDIR} $CONFIG_FILE
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

make_a_fucking_defconfig
compile
deploy
zipit
