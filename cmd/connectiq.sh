#!/bin/bash

# --- Host path configuration ---
GARMIN_DATA="$HOME/.GARMIN_SDK/Garmin"
GARMIN_ROOT="$HOME/.GARMIN_SDK/garmin.connectiq.sdkmanager-root"
IMAGE_NAME="connectiq-sdk"
DEVELOPER_KEY="$HOME/.GARMIN_SDK/developer_key"
CONTAINER_BIN="podman"

# Systematic X11 authorization for both modes
xhost +local:docker

# This function encapsulates all the Podman complexity
launch_container() {
    local mode=$1
    shift # Remove the mode to keep only the remaining arguments ($@)

    # 1. Common arguments for all launches
    local podman_args=(
        "-it" "--rm"
        "-e" "DISPLAY=$DISPLAY"
        "-e" "NO_AT_SPI=1"
        "-v" "/tmp/.X11-unix:/tmp/.X11-unix"
        "-v" "$DEVELOPER_KEY:/root/developer_key:Z"
        "-v" "$GARMIN_ROOT:/root/garmin.connectiq.sdkmanager-root:Z"
        "-v" "$GARMIN_DATA:/root/.Garmin:Z"
        "-w" "/root/"
    )

    # 2. Specific addition for 'run' and 'compile' modes (mounting current project)
    if [ "$mode" == "run" -o "$mode" == "compile" ]; then
        podman_args+=("-v" "$(pwd):/home/sdk:Z")
    fi

    # 3. Final execution
    $CONTAINER_BIN run "${podman_args[@]}" $IMAGE_NAME /usr/local/bin/ciq-tool "$mode" "$@"
}

case "$1" in
    "shell")
        echo "📦 Launching /bin/bash"
        $CONTAINER_BIN run -it --rm \
            -e DISPLAY=$DISPLAY \
            -e NO_AT_SPI=1 \
            -v "$GARMIN_ROOT":/root/garmin.connectiq.sdkmanager-root:Z \
            -v "$GARMIN_DATA":/root/.Garmin:Z \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -w /root/ \
            $IMAGE_NAME /bin/bash
        ;;
    "sdk")
        echo "📦 Launching SDK Manager..."
        launch_container "sdk"
        ;;

    "run")
        DEVICE=${2:-"fenix9pro47mm"}
        echo "🚀 Building and running project for $DEVICE..."
        launch_container "run" "$DEVICE"
        ;;
        
    "compile")
        echo "🛠️ Compiling..."
        launch_container "compile"
        echo "🛠️ After compilation, upload app to: https://apps.garmin.com/developer/dashboard"
        ;;
        
    "list-devices")
        echo "⌚ List all devices..."
        launch_container "list-devices"
        ;;

    *)
        echo "Usage: ./connectiq.sh {sdk|run [device]|shell}"
        echo "  sdk           : Launches the SDK Manager"
        echo "  run [device]  : Compiles and runs the project (default: fenix9pro47mm)"
        echo "  shell         : Opens a terminal in the container"
        echo "  list-devices  : Lists all registered devices in XML format"
        echo "  compile       : Compiles the current project in .iq format for upload to Garmin"
        exit 1
        ;;
esac
