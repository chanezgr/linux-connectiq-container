# Garmin ConnectIQ SDK Container

This project provides a containerized environment to run the Garmin ConnectIQ SDK on Linux, eliminating the need to manually manage Java and GUI dependencies on your host system.

## Getting Started

### 1. Download the SDK Manager
To comply with license restrictions, the SDK manager is not included in this repository. You must download it manually:
- Download the **Garmin ConnectIQ SDK Manager for Linux**.
- Place the downloaded zip file in the `container/` directory.
- Ensure the file is named exactly: `connectiq-sdk-manager-linux.zip`

### 2. Build the Container
Build the Docker/Podman image using the default name `connectiq-sdk`:

```bash
cd container
docker build -t connectiq-sdk .
```
*(If you are using Podman, replace `docker` with `podman`)*.

### 3. Configure the Runner Script
The `cmd/connectiq.sh` script handles the container orchestration. Before using it, you must configure the host paths:
- Open `cmd/connectiq.sh` in a text editor.
- Update the `DEVELOPER_KEY` variable to point to the absolute path of your Garmin developer key on your host machine.
- You can also adjust `GARMIN_DATA` and `GARMIN_ROOT` if you wish to store the SDK data elsewhere.
- Ensure the directories specified in `GARMIN_ROOT` and `GARMIN_DATA` exist on your host.
- You can switch from podman to docker as container manager

## Usage

The `connectiq.sh` script allows you to perform SDK tasks without manually managing container flags.

**Important:** You must run `./connectiq.sh sdk` first to install the SDK and select a default version. Other commands (`run`, `compile`) will fail with a "No default SDK specified" error if this step is skipped.

| Command | Description |
|----------|-------------|
| `./connectiq.sh sdk` | Launches the SDK Manager GUI |
| `./connectiq.sh run [device]` | Compiles and runs the project (Default: `fenix9pro47mm`) |
| `./connectiq.sh compile` | Compiles the project for upload (generates `.iq` file) |
| `./connectiq.sh list-devices` | Lists all registered devices in XML format |
| `./connectiq.sh shell` | Opens an interactive bash shell inside the container |

## Additional Information

### GUI Support
The script automatically executes `xhost +local:docker` to allow the container to display GUI windows (like the SDK Manager) on your host's X11 server.

### Persistence
To ensure your SDK installation and settings are not lost when the container is deleted, the following directories are mapped from the host:
- `~/.GARMIN_SDK/garmin.connectiq.sdkmanager-root` $\rightarrow$ SDK Root
- `~/.GARMIN_SDK/Garmin` $\rightarrow$ Garmin Data
- `[Your Developer Key Path]` $\rightarrow$ `/root/developer_key`
