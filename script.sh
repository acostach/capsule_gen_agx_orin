#!/bin/bash

if [ "$EUID" -ne 0 ]; then
   echo "Please use sudo or run this script as root"
   exit
fi

WORKDIR="/home/acotsach/capsule/"

mkdir -p $WORKDIR
cp ./uefi_jetson.bin ${WORKDIR}/
cd $WORKDIR

sudo apt-get update && apt-get install -y python2 python3 python3-pip usbutils curl lbzip2 git wget unzip e2fsprogs dosfstools libxml2-utils qemu-user-static sudo cpio && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
    pip3 install pyyaml

mkdir -p 35.2.1
cd 35.2.1

if [ ! -d Linux_for_Tegra ]; then 
    wget https://developer.nvidia.com/downloads/jetson-linux-r3521-aarch64tbz2 -O jetson_linux_r35.2.1_aarch64.tbz2 && \
    sudo tar xf jetson_linux_r35.2.1_aarch64.tbz2 ;
else
    echo "L4T 35.2.1 directory already exists"
fi;


if [ ! -e rootfs.tbz2 ]; then
    wget https://developer.nvidia.com/downloads/linux-sample-root-filesystem-r3521aarch64tbz2 -O rootfs.tbz2 ;
    cd Linux_for_Tegra/rootfs/ && sudo tar xpf ../../rootfs.tbz2 && \
    echo "L4T 35.2.1 rootfs already exists"
fi;
    
cd $WORKDIR
mkdir -p 35.3.1
cd 35.3.1

if [ ! -d Linux_for_Tegra ]; then
    wget https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/jetson_linux_r35.3.1_aarch64.tbz2/ -O jetson_linux_r35.3.1_aarch64.tbz2 &&
    sudo tar xf jetson_linux_r35.3.1_aarch64.tbz2 
else
    echo "L4T 35.3.1 BSP already exists"
fi

if [ ! -e rootfs.tbz2 ]; then
    wget https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/tegra_linux_sample-root-filesystem_r35.3.1_aarch64.tbz2/ -O rootfs.tbz2 && \
    cd Linux_for_Tegra/rootfs/ && sudo tar xpf ../../rootfs.tbz2
else
    echo "L4T 35.3.1 rootfs already exists"
fi

cd "${WORKDIR}/35.2.1/Linux_for_Tegra/" && sudo ./apply_binaries.sh && cd "${WORKDIR}/35.3.1/Linux_for_Tegra/" && sudo ./apply_binaries.sh

TARGET_BSP="${WORKDIR}/35.3.1/Linux_for_Tegra" && \
BASE_BSP="${WORKDIR}/35.2.1/Linux_for_Tegra" && \

cd "${WORKDIR}/35.3.1/Linux_for_Tegra/../"
if [ ! -e ota_tools_r35.3.1_aarch64.tbz2 ] ; then
    wget https://developer.nvidia.com/downloads/embedded/l4t/r35_release_v3.1/release/ota_tools_r35.3.1_aarch64.tbz2 && \
    sudo tar xpf ota_tools_r35.3.1_aarch64.tbz2
else
    echo "OTA tools already unpacked"
fi    

cp "${WORKDIR}/uefi_jetson.bin" "${WORKDIR}/35.3.1/Linux_for_Tegra/bootloader/"

cd "${WORKDIR}/35.3.1/Linux_for_Tegra/" && \
sudo -E ./tools/ota_tools/version_upgrade/l4t_generate_ota_package.sh -b jetson-agx-orin-devkit R35-2 && \
cp "${WORKDIR}/35.3.1/Linux_for_Tegra/bootloader/jetson-agx-orin-devkit/ota_payload_package.tar.gz" "${WORKDIR}/"


