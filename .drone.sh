#!/usr/bin/env bash
echo "Cloning dependencies"
apt-get -y install sudo python3-pip curl unzip p7zip-full curl python2 binutils-aarch64-linux-gnu wget binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi libtinfo5 -yq xxd python build-essential make gcc-aarch64-linux-gnu
sudo ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
git clone --depth=1 https://github.com/hydrangea07/kernel_oneplus_kebab -b test kernel && cd kernel
git clone --depth=1 https://github.com/hydrangea07/AnyKernel3 AnyKernel3
git clone --depth=1 https://github.com/pkm774/android-kernel-tools ktools
echo "Done"
           
           
START=$(date +"%s")
PATH="$(pwd)/ktools/sdclang/linux-x86_64/bin:$PATH"
export ARCH=arm64
export SUBARCH=ARM64
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_BUILD_HOST="laplace"
export KBUILD_BUILD_USER="alexandria"

# Compile plox
function compile() {
  
make \
	O=out \
	clean \
	mrproper \
	CC=clang \
	vendor/kona-perf_defconfig
    
make \
	O=out \
	CC=clang \
	-j$(nproc --all)

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


