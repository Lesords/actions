#!/bin/bash

status=0
ignoreFile=ignore.list
logFile=build.log
fqbnList=(
    "Seeeduino:samd:seeed_XIAO_m0"
    "Seeeduino:nrf52:xiaonRF52840"
    "Seeeduino:nrf52:xiaonRF52840Sense"
    "Seeeduino:renesas_uno:XIAO_RA4M1"
    "rp2040:rp2040:seeed_xiao_rp2040"
    "rp2040:rp2040:seeed_xiao_rp2350"
    "esp32:esp32:XIAO_ESP32C3"
    "esp32:esp32:XIAO_ESP32C6"
    "esp32:esp32:XIAO_ESP32S3"
)
exampleList=$(ls examples)

function installRepoAsLib() {
    mkdir -p "$HOME/Arduino/libraries"
    ln -s "$PWD" "$HOME/Arduino/libraries/."
}

# $1 name, $2 url
function installCore() {
    if [ "$2" ]; then
        arduino-cli core update-index --additional-urls $2 >/dev/null 2>&1
        arduino-cli core install $1 --additional-urls $2 >/dev/null 2>&1
    else
        arduino-cli core update-index >/dev/null 2>&1
        arduino-cli core install $1 >/dev/null 2>&1
    fi

    if [ $? -eq 0 ]; then
        echo "$1 install successful"
    else
        echo "$1 install failed"
    fi
}

# $1 fqbn, $2 path
function buildSketch() {
    arduino-cli compile --fqbn $1 $2 --warnings more
}



function init() {
    echo -e "\e[33mStart initializing the compilation environment\e[0m"
    installRepoAsLib

    installCore   arduino:avr
    installCore   esp32:esp32
    installCore   Seeeduino:samd          https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
    installCore   seeeduino:nrf52         https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
    installCore   seeeduino:renesas_uno   https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
    installCore   rp2040:rp2040           https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json
}

function main() {
    init

    for fqbn in ${fqbnList[*]}
    do
        for example in $exampleList
        do
            if [ -f $ignoreFile ] && [ "$(grep -i "$example.*$fqbn" $ignoreFile)" ]; then
                echo -e "Skip $example on $fqbn\n "
                echo -e "Skip $example on $fqbn" >> $logFile
                continue
            fi

            buildSketch $fqbn examples/$example

            if [ $? -eq 0 ]; then
                echo -e "\e[31mBuild $example on $fqbn successful\e[0m\n "
                echo -e "\e[31mBuild $example on $fqbn successful\e[0m" >> $logFile
            else
                status=1
                echo -e "\e[31mBuild $example on $fqbn failed\e[0m\n "
                echo -e "\e[31mBuild $example on $fqbn failed\e[0m" >> $logFile
            fi
        done
    done

    echo -e "\e[33mCompilation results\e[0m" && cat $logFile
    exit $status
}

main
