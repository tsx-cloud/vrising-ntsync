#!/bin/bash

ARCH=$(uname -m)

if [[ "$ARCH" == "aarch64" ]]; then
    echo "Push arm64-box..."
    docker push tsxcloud/vrising-ntsync:arm64
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "Building for amd64..."
    docker push tsxcloud/vrising-ntsync:amd64
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
