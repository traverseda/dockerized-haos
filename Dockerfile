FROM scratch

# Copy the entire extracted rootfs into the image
COPY extracted_rootfs/ /

# Set up any necessary metadata
LABEL org.opencontainers.image.title="Home Assistant OS"
LABEL org.opencontainers.image.description="Docker image based on Home Assistant OS root filesystem"
LABEL org.opencontainers.image.vendor="Home Assistant"

# Set the default command
CMD ["/bin/sh"]
