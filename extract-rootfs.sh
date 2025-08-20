#! /usr/bin/env nix-shell
#! nix-shell -i bash -p erofs-utils bash curl squashfsTools

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo to preserve all file attributes"
    exit 1
fi

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

# Check if rootfs.img exists in the extracted contents
if [ ! -f "rootfs/rootfs.img" ]; then
    echo "rootfs/rootfs.img not found!"
    exit 1
fi

# Create mount point and extraction directory
mount_point=$(mktemp -d)
extracted_rootfs="extracted_rootfs"

echo "Mounting EROFS image..."
# Mount the EROFS image using erofsfuse
erofsfuse "rootfs/rootfs.img" "$mount_point"

# Wait a moment for the mount to be ready
sleep 2

# Copy contents to the extraction directory, preserving all attributes
echo "Copying contents to $extracted_rootfs..."
mkdir -p "$extracted_rootfs"
# Use rsync to better handle copying while preserving all attributes
rsync -aAX "$mount_point"/ "$extracted_rootfs/"

# Unmount
fusermount -u "$mount_point"
rmdir "$mount_point"

echo "Extraction complete. EROFS contents are in the '$extracted_rootfs' directory."
echo "All file attributes have been preserved."
