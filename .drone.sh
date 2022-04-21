#!/usr/bin/env bash
echo "Cloning dependencies"
apt-get -y install sudo python3-pip curl unzip p7zip-full curl python2 binutils-aarch64-linux-gnu wget binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi libtinfo5 -yq xxd python build-essential make
sudo ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
git clone --depth=1 https://github.com/alexandriaC7/kernel_oneplus_kebab kernel && cd kernel
#git clone --depth=1 https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r450784 clang
#git clone https://github.com/greenforce-project/gcc-arm64 --depth=1 gcc
#git clone https://github.com/greenforce-project/gcc-arm32 --depth=1 gcc32
git clone --depth=1 https://github.com/alexandriaC7/AnyKernel3 AnyKernel3
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/misc prebuilts/misc
echo "Done"

DTC=$(pwd)/prebuilts/misc/linux-x86/dtc/dtc
DTC_EXT=$(pwd)/prebuilts/misc/linux-x86/dtc/dtc
IMAGE=$(pwd)/out/arch/arm64/boot/Image
START=$(date +"%s")
KERNEL_DIR=$(pwd)
PATH="${PWD}/clang/bin:$PATH"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_HOST="laplace"
export KBUILD_BUILD_USER="alexandria"

# Compile plox
function compile() {
    make O=out ARCH=arm64 vendor/kona-perf_defconfig
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CC=clang \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi-

}

compile

# Build flashable zip
cp out/arch/arm64/boot/Image AnyKernel3/
cp out/arch/arm64/boot/dtbo.img AnyKernel3/
zipfile="./out/kernel-lemonkebab-$(date +%Y%m%d-%H%M).zip"
7z a -mm=Deflate -mfb=258 -mpass=15 -r $zipfile ./AnyKernel3/*

END=$(date +"%s")
DIFF=$(($END - $START))
curl --upload-file $zipfile https://transfer.sh; echo
sleep 2
#sometimes transfer.sh couldnt save metadata 
curl -F "file=@$zipfile" https://file.io


