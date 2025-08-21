FROM scratch

# Copy the entire extracted rootfs into the image
COPY extracted_rootfs/ /

# Set up any necessary metadata
LABEL org.opencontainers.image.title="Home Assistant OS"
LABEL org.opencontainers.image.description="Docker image based on Home Assistant OS root filesystem"
LABEL org.opencontainers.image.vendor="traverseda"

RUN systemctl disable hassos-data.service hassos-boot.service hassos-overlay.service mnt-overlay.mount mnt-boot.mount mnt-data.mount ha-cli@tty1.service rauc.service auditd.service haos-mglru.service hassos-persists.service haos-swapfile.service

# Create modified supervisor service file
COPY ./root_overlay/etc/systemd/system/hassos-supervisor.service /etc/systemd/system/hassos-supervisor.service

# Set the default command with flags to make systemd work better in a container
CMD ["/sbin/init", "--log-level=info", "--log-target=console"]
