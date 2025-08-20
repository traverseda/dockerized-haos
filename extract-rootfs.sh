#! /usr/bin/env nix-shell
#! nix-shell -i bash -p erofs-utils bash curl squashfsTools

set -e

rootfs_url="https://github.com/home-assistant/operating-system/releases/download/16.1/haos_generic-x86-64-16.1.raucb"
filename=$(basename "$rootfs_url")

# Download the RAUC bundle if it doesn't exist
if [ ! -f "$filename" ]; then
    echo "Downloading $filename..."
    curl -L -O "$rootfs_url"
fi

# Extract the .raucb file using unsquashfs
echo "Extracting $filename..."
unsquashfs -f -d rootfs "$filename"

echo "Extraction complete. Contents are in the 'rootfs' directory."
