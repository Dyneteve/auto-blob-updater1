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
    echo "Build Dependencies Installed....."
    GH_PERSONAL_TOKEN=$(cat /tmp/gh_token)
    CURR_DIR=$(pwd)
}

rom() {
    python3 get_rom.py
    unzip rom.zip -d miui > /dev/null 2>&1
    cd miui
}

dec_brotli() {
    echo "Decompressing brotli....."
    brotli --decompress system.new.dat.br
    brotli --decompress vendor.new.dat.br
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
    cd $CURR_DIR
}

build_conf() {
    mkdir repo && cd repo
    git config --global user.email "sound0020@gmail.com"
    git config --global user.name "Dyneteve"
}

google_cookie() {
    git clone https://Dyneteve:${GH_PERSONAL_TOKEN}@github.com/Dyneteve/google.git cookie > /dev/null 2>&1
    cd cookie && bash cookie.sh && cd ..
}

init_repo() {
    echo "Repo initialised......."
    repo init -u git://github.com/PixelExperience/manifest.git -b pie --depth=1 > /dev/null 2>&1
    echo "Repo Syncing started......"
    repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc) -q > /dev/null 2>&1
    echo -e "\e[32mRepo Synced....."
}

dt() {
    echo "Cloning device tree......."
    git clone https://github.com/Dyneteve/davinci_listfiles -b pie device/xiaomi/violet > /dev/null 2>&1
    git clone https://github.com/PixelExperience-Devices/vendor_xiaomi_violet -b pie vendor/xiaomi/violet > /dev/null 2>&1
    cd device/xiaomi/violet
}

gen_blob() {
    bash extract-files.sh --no-cleanup $CURR_DIR/miui
    echo "Blobs Generated!"
}

push_vendor() {
    cd $CURR_DIR/repo/vendor/xiaomi/violet
    git remote rm origin
    git remote add origin https://Dyneteve:${GH_PERSONAL_TOKEN}@github.com/Dyneteve/vendor_xiaomi_violet.git
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
google_cookie
init_repo
dt
gen_blob
push_vendor
