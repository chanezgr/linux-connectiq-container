#!/bin/bash
# This script is embeeded into the container
if [[ "$1" != "sdk" && "$1" != "list-devices" ]] && [ ! -s /root/.Garmin/ConnectIQ/current-sdk.cfg ]; then
    echo "No default SDK specified" >&2
    exit 1
fi

SDK_PATH=$(cat /root/.Garmin/ConnectIQ/current-sdk.cfg)
BIN_PATH=$SDK_PATH/bin
DEVELOPER_KEY=/root/developer_key

chmod +x $BIN_PATH/*

case "$1" in
    "sdk")
        /root/sdk-manager/bin/sdkmanager --update
        ;;
    "run")
        DEVICE=${2:-"fenix9pro47mm"}
        $BIN_PATH/simulator &
        $BIN_PATH/monkeyc -d $DEVICE -f /home/sdk/monkey.jungle -o /home/sdk/temp/built/$DEVICE.prg -y $DEVELOPER_KEY
        $BIN_PATH/monkeydo /home/sdk/temp/built/$DEVICE.prg $DEVICE
        wait
        ;;
    "compile")
        APPNAME=${2:-"app"}
        chmod +x $BIN_PATH/*	
        $BIN_PATH/monkeyc -e -o /home/sdk/built/$APPNAME.iq -w -f /home/sdk/monkey.jungle -y $DEVELOPER_KEY
        ;;
    "list-devices")
        DEVICES="/root/.Garmin/ConnectIQ/Devices/"
        for d in $(find "$DEVICES" -mindepth 1 -type d)
        do
            folder=$(basename "$d")
            device=$(echo "$folder" | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
            echo "<iq:product id=\"$device\"/>"
        done
        ;;
    esac
