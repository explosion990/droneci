#!/bin/bash
#

START=$(date +"%s")
export KBUILD_BUILD_HOST=07
export KBUILD_BUILD_USER="alexandria"
TC_DIR="$HOME/tc/aosp-clang"
GCC_64_DIR="$HOME/tc/aarch64-linux-android-4.9"
GCC_32_DIR="$HOME/tc/arm-linux-androideabi-4.9"
AK3_DIR="$HOME/android/AnyKernel3"
DEFCONFIG="vendor/kona-perf_defconfig"
VERSION="$(cat arch/arm64/configs/vendor/kona-perf_defconfig | grep "CONFIG_LOCALVERSION\=" | sed -r 's/.*"(.+)".*/\1/' | sed 's/^.//')"

echo "Cloning dependencies"
apt-get -y install sudo python3-pip curl unzip p7zip-full curl python2 binutils-aarch64-linux-gnu wget binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi libtinfo5 -yq xxd python
sudo ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
git clone --depth=1 https://github.com/ArrowOS-Devices/android_prebuilts_clang_host_linux-x86_clang-r428724 $TC_DIR
git clone https://github.com/sohamxda7/llvm-stable -b gcc64 --depth=1 $GCC_64_DIR
git clone https://github.com/sohamxda7/llvm-stable -b gcc32  --depth=1 $GCC_32_DIR
echo "Done"

export PATH="$TC_DIR/bin:$PATH"

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=$GCC_64_DIR/bin/aarch64-linux-android- CROSS_COMPILE_ARM32=$GCC_32_DIR/bin/arm-linux-androideabi- CLANG_TRIPLE=aarch64-linux-gnu- Image.gz dtbo.img

kernel="out/arch/arm64/boot/Image"
dtb="out/arch/arm64/boot/dts/qcom/kona.dtb"
dtbo="out/arch/arm64/boot/dtbo.img"

# Build flashable zip
cp out/arch/arm64/boot/Image AnyKernel3/
cp out/arch/arm64/boot/dtbo.img AnyKernel3/
zipfile="./out/$VERSION-lemonkebab-$(date +%Y%m%d-%H%M).zip"
7z a -mm=Deflate -mfb=258 -mpass=15 -r $zipfile ./AnyKernel3/*

END=$(date +"%s")
DIFF=$(($END - $START))
curl --upload-file $zipfile https://transfer.sh; echo
sleep 2
#sometimes transfer.sh couldnt save metadata 
curl -F "file=@$zipfile" https://file.io

