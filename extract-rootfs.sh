#! /usr/bin/env bash

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo to preserve all file attributes"
    exit 1
fi

# Get the release tag from the first argument, or use latest
RELEASE_TAG=${1:-latest}
echo "Processing release: $RELEASE_TAG"

# Determine the download URL based on the release tag
if [ "$RELEASE_TAG" == "latest" ]; then
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/home-assistant/operating-system/releases/latest | jq -r '.assets[] | select(.name | endswith(".raucb")) | .browser_download_url' | head -n 1)
else
    DOWNLOAD_URL=$(curl -s https://api.github.com/repos/home-assistant/operating-system/releases/tags/$RELEASE_TAG | jq -r '.assets[] | select(.name | endswith(".raucb")) | .browser_download_url' | head -n 1)
fi

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to find download URL for release $RELEASE_TAG"
    exit 1
fi

filename=$(basename "$DOWNLOAD_URL")

# Download the RAUC bundle if it doesn't exist or if it's different
echo "Downloading $filename..."
curl -L -o "$filename" "$DOWNLOAD_URL"

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

# Clean up the intermediate rootfs directory
rm -rf rootfs

echo "Extraction complete. EROFS contents are in the '$extracted_rootfs' directory."
echo "All file attributes have been preserved."
