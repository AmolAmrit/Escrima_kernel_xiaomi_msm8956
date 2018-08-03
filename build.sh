#!/bin/bash

git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 ~/toolchain
#For Time Calculation
BUILD_START=$(date +"%s")

kernel_version="JackFix"
kernel_name="EscrimaX25"
device_name="kenzo"
zip_name="$kernel_name-$device_name-$kernel_version-$(date +"%Y%m%d")-$(date +"%H%M%S").zip"

# ccache
# export USE_CCACHE=1

export HOME="/home/amoghmaiya"
export CONFIG_FILE="lineageos_kenzo_defconfig"
export ARCH="arm64"
# export KBUILD_BUILD_USER="amog787"
# export KBUILD_BUILD_HOST="SpaceX"
export TOOLCHAIN_PATH="${HOME}/toolchain"
export CROSS_COMPILE=$TOOLCHAIN_PATH/bin/aarch64-linux-android-
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export objdir="$PWD/obj"
export sourcedir="$PWD/releases"
export anykernel="$PWD/AnyKernel"
export kerneldir="$PWD"
rm -rf $objdir
mkdir $objdir

jackpatch(){
git apply jack.patch
}
compile() {
  make O=$objdir  $CONFIG_FILE -j12
  make O=$objdir -j12
}
clean() {
  make O=$objdir CROSS_COMPILE=${CROSS_COMPILE}  $CONFIG_FILE -j12
  make O=$objdir mrproper
  make O=$objdir clean
}
module_stock(){
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
  ${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/$ARCH/boot/Image.gz-dtb $anykernel/zImage
}
revertjackpatch(){
git apply -R jack.patch
}
delete_zip(){
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}
build_package(){
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}
make_name(){
  mv UPDATE-AnyKernel2.zip $zip_name
}
turn_back(){
rm -rf $sourcedir/*
cp -a $zip_name $sourcedir/
cd $sourcedir
}


upload()
{
# gdrive upload $sourcedir/$zip_name
ls $sourcedir/$zip_name
}

jackpatch
clean
compile
revertjackpatch
module_stock
delete_zip
build_package
make_name
turn_back
upload
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
