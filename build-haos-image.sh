#! /usr/bin/env bash

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root using sudo"
    exit 1
fi

# Get the release tag from the first argument, or use latest
RELEASE_TAG=${1:-latest}
echo "Building for release: $RELEASE_TAG"

# Run the extraction script with the release tag
echo "Running extraction script..."
./extract-rootfs.sh "$RELEASE_TAG"

# Build the Docker image
echo "Building Docker image..."
docker build -t haos:$RELEASE_TAG -t haos:latest .

# Clean up the extracted files
echo "Cleaning up extracted files..."
rm -rf extracted_rootfs

echo "Docker image 'haos' built successfully!"
echo "Temporary files have been cleaned up."
