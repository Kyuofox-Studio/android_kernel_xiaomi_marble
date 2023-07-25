#!/bin/bash

# Device code
LM_DEVICE_CODE=marble
LM_DEVICE_TARGET_CONFIG=${LM_DEVICE_CODE}_GKI_defconfig
# Output dir
LM_OUTPUT_DIR=out
# Common options
LM_BUILD_OPTIONS="ARCH=arm64 SUBARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=$LM_OUTPUT_DIR"
# Available CPU process number
LM_CPU_THREAD_NUM=$(nproc --all)
LM_USED_CPU_PROC_NUM=$LM_CPU_THREAD_NUM

# Calculate CPU_PROC_NUM based on the number of CPU threads
if [[ $LM_CPU_THREAD_NUM -le 4 ]]; then
    LM_USED_CPU_PROC_NUM=$LM_CPU_THREAD_NUM
elif [[ $LM_CPU_THREAD_NUM -le 8 ]]; then
    LM_USED_CPU_PROC_NUM=$(expr $LM_CPU_THREAD_NUM - 2)
else
    LM_USED_CPU_PROC_NUM=$(expr $LM_CPU_THREAD_NUM - 4)
fi

LM_MAKE="make -j$LM_USED_CPU_PROC_NUM $LM_BUILD_OPTIONS"

clang_check() {
    LM_CLANG_VERSION_OUTPUT=`clang --version | head -n 1`

    if [[ "$LM_CLANG_VERSION_OUTPUT" == *"clang version 12.0.5"* ]]; then
        echo "Clang toolchains check passed!"
        return 0
    fi

    echo "You are using unsupported Clang toolchains."
    echo "For android12-5.10 GKI kernel, you must use"
    echo "the Clang 12.0.5 toolchains provided by Google."
    echo "The build process will be continued, but the"
    echo "resulting kernel image may not be able to boot."
}

build_clean() {
    echo "Run mrproper for cleaning."
    $LM_MAKE mrproper
}

build_kernel() {
    clang_check

    echo "Build GKI kernel for device: $LM_DEVICE_CODE"
    echo "Clang Information:"
    clang --version
    echo "Build Information:"
    echo "  Target: $LM_DEVICE_CODE"
    echo "  Build config: $LM_DEVICE_TARGET_CONFIG"
    echo "  Build options: $LM_BUILD_OPTIONS"

    echo "Generate configurate file."
    $LM_MAKE $LM_DEVICE_TARGET_CONFIG

    echo "Start building with $LM_USED_CPU_PROC_NUM threads..."
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
    echo "Your persist Clang toolchains:"
    clang --version
    echo "To change this, you may need to set \$PATH"
elif [[ $1 == "help" ]]; then
    echo "Allowed subcommands: [kernel, clean, status, help]."
else
    echo "Invalid parameter, please type help for more information."
fi
