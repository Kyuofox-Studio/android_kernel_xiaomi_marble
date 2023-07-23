#!/bin/bash

# Device code
LM_DEVICE_CODE=marble
# Output dir
LM_OUTPUT_DIR=out
# Common options
LM_BUILD_OPTIONS=ARCH="arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=$LM_OUTPUT_DIR"
# Available CPU process number
LM_CPU_THREAD_NUM=$(nproc --all)
LM_USED_CPU_PROC_NUM=$LM_CPU_THREAD_NUM

# 根据CPU线程数计算CPU_PROC_NUM
if [[ $LM_CPU_THREAD_NUM -le 4 ]]; then
  LM_USED_CPU_PROC_NUM=$LM_CPU_THREAD_NUM
elif [[ $LM_CPU_THREAD_NUM -le 8 ]]; then
  LM_USED_CPU_PROC_NUM=$(expr $LM_CPU_THREAD_NUM - 2)
else
  LM_USED_CPU_PROC_NUM=$(expr $LM_CPU_THREAD_NUM - 4)
fi

LM_MAKE="make -j$LM_USED_CPU_PROC_NUM $LM_BUILD_OPTIONS"

build_clean() {
  echo "Run mrproper for cleaning."
  $LM_MAKE mrproper
}

build_kernel() {
  echo "Build GKI kernel for device: ${LM_DEVICE_CODE}"
  echo "Generate config by using the GKI config file."
  $LM_MAKE gki_defconfig
  echo "Apply device config files to config."
#  $LM_MAKE vendor/${LM_DEVICE_CODE}_GKI.config
  $LM_MAKE vendor/${LM_DEVICE_CODE}_tuivm.config
  clear
  
  echo "Build GKI kernel for device: ${LM_DEVICE_CODE}"
  echo "Start building..."
  $LM_MAKE
  
}

if [[ -z $1 || $1 == "kernel" ]]; then
  build_kernel
elif [[ $1 == "clean" ]]; then
  build_clean
elif [[ $1 == "status" ]]; then
  echo "Used CPU process number: $LM_USED_CPU_PROC_NUM"
  echo "Used options for building: $LM_BUILD_OPTIONS"
  echo "Output directory: $LM_OUTPUT_DIR"
elif [[ $1 == "help" ]]; then
  echo "Allowed subcommands: [kernel, clean, status, help]."
else
  echo "Invalid parameter, please type help for more information."
fi
