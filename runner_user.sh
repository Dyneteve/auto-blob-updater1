#!/bin/bash
# Copyright (C) 2019 The Raphielscape Company LLC.
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for Generation of blobs

# We need this directive
# shellcheck disable=1090

build_env() {
    export LOC=$(cat /tmp/loc)
    cd ~
    sudo apt install patchelf brotli unzip zip repo p7zip-full -y > /dev/null 2>&1
    pip3 install requests > /dev/null 2>&1
    echo "Build Dependencies Installed....."
}

rom() {
    mkdir extract
    cd extract
    sudo mv $LOC/get_rom.py get_rom.py
    python3 get_rom.py
    unzip rom.zip -d miui > /dev/null 2>&1
    cd miui
}

dec_brotli() {
    brotli --decompress system.new.dat.br
    brotli --decompress vendor.new.dat.br
    echo "Brotli decompressed....."
}

sdatimg() {
    echo "Converting to img....."
    curl -sLo sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
    python3 sdat2img.py system.transfer.list system.new.dat > /dev/null 2>&1
    python3 sdat2img.py vendor.transfer.list vendor.new.dat vendor.img > /dev/null 2>&1
}

extract() {
    echo "Extracting the img's....."
    mkdir system
    mkdir vendor
    7z x system.img -y -osystem > /dev/null 2>&1
    7z x vendor.img -y -ovendor > /dev/null 2>&1
    cd ~
}

build_conf() {
    mkdir repo
    cd repo
    git config --global user.email "sound0020@gmail.com"
    git config --global user.name "Dyneteve"
}

init_repo() {
    echo "Repo initialised......."
    repo init -u https://github.com/PixelExperience/manifest -b pie --depth=1 > /dev/null 2>&1
    echo "Repo Syncing started......"
    repo sync -j$(nproc) --no-tags --no-clone-bundle -c > /dev/null 2>&1
    echo -e "\e[32mRepo Synced....."
}

dt() {
    echo "Cloning device tree......."
    git clone https://github.com/Dyneteve/davinci_listfiles -b pie device/xiaomi/violet > /dev/null 2>&1
    git clone https://github.com/PixelExperience-Devices/vendor_xiaomi_violet -b pie vendor/xiaomi/violet > /dev/null 2>&1
    cd device/xiaomi/violet
}

gen_blob() {
    bash extract-files.sh --no-cleanup ~/extract/miui
    echo "Blobs Generated!"
}

push_vendor() {
    cd ~/repo/vendor/xiaomi/violet
    git remote rm origin
    git remote add origin https://Dyneteve:$(cat /tmp/GH_TOKEN)@github.com/Dyneteve/vendor_xiaomi_violet.git
    git add .
    git commit -m "violet: Update vendor blobs from davinci" --signoff
    git checkout -b $(cat /tmp/version)
    git push --force origin $(cat /tmp/version)
    echo "Job Successful!"
}

build_env
rom
dec_brotli
sdatimg
extract
build_conf
init_repo
dt
gen_blob
push_vendor
