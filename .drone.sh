#!/usr/bin/env bash
echo "Cloning dependencies"
apt-get -y install sudo python3-pip curl unzip p7zip-full curl python2 binutils-aarch64-linux-gnu wget binutils-aarch64-linux-gnu binutils-arm-linux-gnueabi libtinfo5 -yq xxd python build-essential make gcc-aarch64-linux-gnu
sudo ln -sf /usr/share/zoneinfo/Asia/Singapore /etc/localtime
git clone --depth-1 https://github.com/str-br/android_kernel_oneplus_sm8250 kernel && cd kernel
git clone --depth=1 https://github.com/hydrangea07/AnyKernel3 AnyKernel3
git clone --depth=1 https://github.com/pkm774/android-kernel-tools ktools
echo "Done"
           
           
START=$(date +"%s")
PATH="$(pwd)/ktools/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:$PATH"
PATH="$(pwd)/ktools/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH"
PATH="$(pwd)/ktools/clang/host/linux-x86/clang-r428724/bin:$PATH"
export ARCH=arm64
export SUBARCH=ARM64
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-
export KBUILD_BUILD_HOST="str"
export KBUILD_BUILD_USER="143"
export OEM_TARGET_PRODUCT=kebab

# Compile plox
function compile() {
   make \
   	O=out \
	CC=clang \
	AS=llvm-as \
	AR=llvm-ar \
	NM=llvm-nm \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	STRIP=llvm-strip \
	LLVM=1 \
	LLVM_IAS=1 \
	HOSTCC=clang \
	HOSTCXX=clang++ \
	HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument" \
	vendor/kona-perf_defconfig
	
   make \
   	O=out \
	CC=clang \
	AS=llvm-as \
	AR=llvm-ar \
	NM=llvm-nm \
	OBJCOPY=llvm-objcopy \
	OBJDUMP=llvm-objdump \
	STRIP=llvm-strip \
	LLVM=1 \
	LLVM_IAS=1 \
	HOSTCC=clang \
	HOSTCXX=clang++ \
	HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument" \
	-j$(nproc --all)
}

compile

# Build flashable zip
cp out/arch/arm64/boot/Image AnyKernel3/
zipfile="./out/kernel-lemonkebab-$(date +%Y%m%d-%H%M).zip"
7z a -mm=Deflate -mfb=258 -mpass=15 -r $zipfile ./AnyKernel3/*

END=$(date +"%s")
DIFF=$(($END - $START))
curl --upload-file $zipfile https://transfer.sh; echo
sleep 2
#sometimes transfer.sh couldnt save metadata 
curl -sL https://git.io/file-transfer | sh && ./transfer wet "file=@$zipfile"

