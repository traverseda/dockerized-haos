#! /usr/bin/env bash

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo"
    exit 1
fi

# Run the extraction script
echo "Running extraction script..."
./extract-rootfs.sh

# Build the Docker image
echo "Building Docker image..."
docker build -t haos .

# Clean up the extracted files
echo "Cleaning up extracted files..."
rm -rf extracted_rootfs

echo "Docker image 'haos' built successfully!"
echo "Temporary files have been cleaned up."
