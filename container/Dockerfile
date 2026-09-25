FROM ubuntu:20.04
# On évite les prompts interactifs pendant l'install
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt update && apt install -y \
    libwebkit2gtk-4.0-37 \
    libgtk-3-0 \
    libcurl4 \
    libsm6 \
    libice6 \
    libx11-6 \
    libxext6 \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    unzip \
    default-jre \
    libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/sdk-manager/
COPY connectiq-sdk-manager-linux.zip /root/sdk-manager/
RUN cd /root/sdk-manager && unzip connectiq-sdk-manager-linux.zip && rm connectiq-sdk-manager-linux.zip

COPY ciq-tool.sh /usr/local/bin/ciq-tool
RUN chmod +x /usr/local/bin/ciq-tool

CMD ["bash"]
